#ifndef LCD
#define LCD
  void lcdCommand(char value);
  void lcdCommand_nodelay(char value); 
  void lcdChar(char value);
  void lcdChar_nodelay(char value);
  void lcdString(char msg[]);
  void lcdNumber(int value);
  void lcdPosition(int line, int col);
  void lcdInit(void);
#endif
