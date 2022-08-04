/*
 * PCD8544 - Interface with Philips PCD8544 (or compatible) LCDs.
 *
 * Copyright (c) 2010 Carlos Rodrigues <cefrodrigues@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


#include "PCD8544.h"

#if ARDUINO < 100
#include <WProgram.h>
#else
#include <Arduino.h>
#endif

#include <pgmspace.h>


#define PCD8544_CMD  LOW
#define PCD8544_DATA HIGH


/*
 * If this was a ".h", it would get added to sketches when using
 * the "Sketch -> Import Library..." menu on the Arduino IDE...
 */
#include "charset.cpp"


PCD8544::PCD8544(unsigned char sclk, unsigned char sdin,
                 unsigned char dc, unsigned char reset,
                 unsigned char sce):
    pin_sclk(sclk),
    pin_sdin(sdin),
    pin_dc(dc),
    pin_reset(reset),
    pin_sce(sce)
{}


void PCD8544::begin(unsigned char width, unsigned char height, unsigned char model)
{
    this->width = width;
    this->height = height;

    // Only two chip variants are currently known/supported...
    this->model = (model == CHIP_ST7576) ? CHIP_ST7576 : CHIP_PCD8544;

    this->column = 0;
    this->line = 0;

    // Sanitize the custom glyphs...
    memset(this->custom, 0, sizeof(this->custom));

    // All pins are outputs (these displays cannot be read)...
    pinMode(this->pin_sclk, OUTPUT);
    pinMode(this->pin_sdin, OUTPUT);
    pinMode(this->pin_dc, OUTPUT);
    pinMode(this->pin_reset, OUTPUT);
    pinMode(this->pin_sce, OUTPUT);

    // Reset the controller state...
    digitalWrite(this->pin_reset, HIGH);
    digitalWrite(this->pin_sce, HIGH);
    digitalWrite(this->pin_reset, LOW);
    delay(100);
    digitalWrite(this->pin_reset, HIGH);

    // Set the LCD parameters...
    this->send(PCD8544_CMD, 0x21);  // extended instruction set control (H=1)
    this->send(PCD8544_CMD, 0x13);  // bias system (1:48)

    if (this->model == CHIP_ST7576) {
        this->send(PCD8544_CMD, 0xe0);  // higher Vop, too faint at default
        this->send(PCD8544_CMD, 0x05);  // partial display mode
    } else {
        this->send(PCD8544_CMD, 0xc2);  // default Vop (3.06 + 66 * 0.06 = 7V)
    }

    this->send(PCD8544_CMD, 0x20);  // extended instruction set control (H=0)
    this->send(PCD8544_CMD, 0x09);  // all display segments on

    // Clear RAM contents...
    this->clear();

    // Activate LCD...
    this->send(PCD8544_CMD, 0x08);  // display blank
    this->send(PCD8544_CMD, 0x0c);  // normal mode (0x0d = inverse mode)
    delay(100);

    // Place the cursor at the origin...
    this->send(PCD8544_CMD, 0x80);
    this->send(PCD8544_CMD, 0x40);
}


void PCD8544::stop()
{
    this->clear();
    this->setPower(false);
}


void PCD8544::clear()
{
    this->setCursor(0, 0);

    for (unsigned short i = 0; i < this->width * (this->height/8); i++) {
        this->send(PCD8544_DATA, 0x00);
    }

    this->setCursor(0, 0);
}


void PCD8544::clearLine()
{
    this->setCursor(0, this->line);

    for (unsigned char i = 0; i < this->width; i++) {
        this->send(PCD8544_DATA, 0x00);
    }

    this->setCursor(0, this->line);
}


void PCD8544::setPower(bool on)
{
    this->send(PCD8544_CMD, on ? 0x20 : 0x24);
}


inline void PCD8544::display()
{
    this->setPower(true);
}


inline void PCD8544::noDisplay()
{
    this->setPower(false);
}


void PCD8544::setInverse(bool inverse)
{
    this->send(PCD8544_CMD, inverse ? 0x0d : 0x0c);
}


void PCD8544::setContrast(unsigned char level)
{
    // The PCD8544 datasheet specifies a maximum Vop of 8.5V for safe
    // operation in low temperatures, which limits the contrast level.
    if (this->model == CHIP_PCD8544 && level > 90) {
        level = 90;  // Vop = 3.06 + 90 * 0.06 = 8.46V
    }

    // The ST7576 datasheet specifies a minimum Vop of 4V.
    if (this->model == CHIP_ST7576 && level < 36) {
        level = 36;  // Vop = 2.94 + 36 * 0.03 = 4.02V
    }

    this->send(PCD8544_CMD, 0x21);  // extended instruction set control (H=1)
    this->send(PCD8544_CMD, 0x80 | (level & 0x7f));
    this->send(PCD8544_CMD, 0x20);  // extended instruction set control (H=0)
}


void PCD8544::home()
{
    this->setCursor(0, this->line);
}


void PCD8544::setCursor(unsigned char column, unsigned char line)
{
    this->column = (column % this->width);
    this->line = (line % (this->height/9 + 1));

    this->send(PCD8544_CMD, 0x80 | this->column);
    this->send(PCD8544_CMD, 0x40 | this->line);
}


void PCD8544::createChar(unsigned char chr, const unsigned char *glyph)
{
    // ASCII 0-31 only...
    if (chr >= ' ') {
        return;
    }

    this->custom[chr] = glyph;
}


#if ARDUINO < 100
void PCD8544::write(uint8_t chr)
#else
size_t PCD8544::write(uint8_t chr)
#endif
{
    // ASCII 7-bit only...
    if (chr >= 0x80) {
#if ARDUINO < 100
        return;
#else
        return 0;
#endif
    }

    const unsigned char *glyph;
    unsigned char pgm_buffer[5];

    if (chr >= ' ') {
        // Regular ASCII characters are kept in flash to save RAM...
        memcpy_P(pgm_buffer, &charset[chr - ' '], sizeof(pgm_buffer));
        glyph = pgm_buffer;
    } else {
        // Custom glyphs, on the other hand, are stored in RAM...
        if (this->custom[chr]) {
            glyph = this->custom[chr];
        } else {
            // Default to a space character if unset...
            memcpy_P(pgm_buffer, &charset[0], sizeof(pgm_buffer));
            glyph = pgm_buffer;
        }
    }

    // Output one column at a time...
    for (unsigned char i = 0; i < 5; i++) {
        this->send(PCD8544_DATA, glyph[i]);
    }

    // One column between characters...
    this->send(PCD8544_DATA, 0x00);

    // Update the cursor position...
    this->column = (this->column + 6) % this->width;

    if (this->column == 0) {
        this->line = (this->line + 1) % (this->height/9 + 1);
    }

#if ARDUINO >= 100
    return 1;
#endif
}


void PCD8544::drawBitmap(const unsigned char *data, unsigned char columns, unsigned char lines)
{
    unsigned char scolumn = this->column;
    unsigned char sline = this->line;

    // The bitmap will be clipped at the right/bottom edge of the display...
    unsigned char mx = (scolumn + columns > this->width) ? (this->width - scolumn) : columns;
    unsigned char my = (sline + lines > this->height/8) ? (this->height/8 - sline) : lines;

    for (unsigned char y = 0; y < my; y++) {
        this->setCursor(scolumn, sline + y);

        for (unsigned char x = 0; x < mx; x++) {
            this->send(PCD8544_DATA, data[y * columns + x]);
        }
    }

    // Leave the cursor in a consistent position...
    this->setCursor(scolumn + columns, sline);
}


void PCD8544::drawColumn(unsigned char lines, unsigned char value)
{
    unsigned char scolumn = this->column;
    unsigned char sline = this->line;

    // Keep "value" within range...
    if (value > lines*8) {
        value = lines*8;
    }

    // Find the line where "value" resides...
    unsigned char mark = (lines*8 - 1 - value)/8;

    // Clear the lines above the mark...
    for (unsigned char line = 0; line < mark; line++) {
        this->setCursor(scolumn, sline + line);
        this->send(PCD8544_DATA, 0x00);
    }

    // Compute the byte to draw at the "mark" line...
    unsigned char b = 0xff;
    for (unsigned char i = 0; i < lines*8 - mark*8 - value; i++) {
        b <<= 1;
    }

    this->setCursor(scolumn, sline + mark);
    this->send(PCD8544_DATA, b);

    // Fill the lines below the mark...
    for (unsigned char line = mark + 1; line < lines; line++) {
        this->setCursor(scolumn, sline + line);
        this->send(PCD8544_DATA, 0xff);
    }

    // Leave the cursor in a consistent position...
    this->setCursor(scolumn + 1, sline);
}


void PCD8544::send(unsigned char type, unsigned char data)
{
    digitalWrite(this->pin_dc, type);

    digitalWrite(this->pin_sce, LOW);
    shiftOut(this->pin_sdin, this->pin_sclk, MSBFIRST, data);
    digitalWrite(this->pin_sce, HIGH);
}


/* vim: set expandtab ts=4 sw=4: */
