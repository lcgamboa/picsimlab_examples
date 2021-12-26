#ifndef RGB
#define RGB

//todos desligados
#define OFF    0

//cores prim�rias
#define RED    1
#define GREEN  2
#define BLUE   4

//cores secund�rias
#define YELLOW (RED+GREEN)
#define CYAN   (GREEN+BLUE)
#define PURPLE (RED+BLUE)

//todos acesos
#define WHITE  (RED+GREEN+BLUE)

	void rgbColor(int led);
	void turnOn(int led);
	void turnOff(int led);
	void rgbInit(void);
#endif
