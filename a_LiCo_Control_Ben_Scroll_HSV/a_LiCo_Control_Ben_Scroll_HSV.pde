#include <CC2500.h>
#include <ColourConversion.h>
#include <LivingColors.h>

#define MOSI   11    // SPI master data out pin
#define MISO   12    // SPI master data in pin
#define SCK    13    // SPI clock pin
#define CS     10    // SPI slave select pin

#define padding(number,width)  for(int i=1; i < width - log10(number); i++) Serial.print('0'); Serial.println(number,DEC);

LivingColors livcol(CS, SCK, MOSI, MISO);

unsigned char lamp1[9] = { 
  0x7C, 0xB1, 0xE8, 0x4E, 0x27, 0x3B, 0xDC, 0x1D, 0x11 }; // Lamp Ben
unsigned char adress[9] = { 
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
int red = 50;
int green = 255;
int blue = 100;
unsigned int i = 0;
boolean lampOn = false;
boolean echo = true;
unsigned int t = 0;
byte Red = 128;
byte Green = 128;
byte Blue = 128;  

#define BufSize 25
char SerBuf[BufSize];

void setup()
{
  // setup serial port
  Serial.begin(9600);
  //    Serial.println("Starting...");

  livcol.init();
  livcol.clearLamps();
  livcol.addLamp(lamp1);

  Serial.println("!");
  livcol.turnLampOnRGB(0,0,0,0);
  delay(10);
}

void PrintAdress()
{
  for (int l=0; l<livcol.getNumLamps(); l++)
  {
    if (livcol.getLamp(l,adress))
    {
      Serial.print("[");
      Serial.print(l);
      Serial.print("] ");
      for (int x=0; x<9; x++)
      {
        Serial.print(adress[x], HEX);
        Serial.print(", ");
      }
      Serial.println("");
    }
  }
}    

void ClearBuf(void)
{
  for(int i=0; i<BufSize; i++)
  { 
    SerBuf[i]=0; 
  }
}

void ReadLine(void)
{
  int i;
  i=0;
  char c;
  c = 0;
  ClearBuf();
  while((c!=13) && (c!=10) && (i < (BufSize-1)))
  {
    while (!Serial.available())
    {
      // you can do something usefull here
    }
    c = Serial.read();
    if (echo) Serial.print(c);
    if ((c!=13) || (c!=10))
    {
      SerBuf[i] = c;
      i++; 
    }
  }
}

byte Val(char c)
{
  byte t = 0;
  if (c>='0')
    if (c<='9')
    {
      t = c - '0';
      //    Serial.print(t);    
    }
  return t;      
}

byte Val(char c1, char c2, char c3)
{
  return Val(c3) + 10 * Val(c2) + 100 * Val(c1); 
}

byte ValHex(char c)
{
  byte t = 0;
  if (c>='0')
    if (c<='9')
    {
      t = c - '0';
    }
  switch (c)
  {
  case 'a' : 
  case 'A' : 
    t = 10;
  case 'b' : 
  case 'B' : 
    t = 11;
  case 'c' : 
  case 'C' : 
    t = 12;
  case 'd' : 
  case 'D' : 
    t = 13;
  case 'e' : 
  case 'E' : 
    t = 14;
  case 'f' : 
  case 'F' : 
    t = 15;
  }    
  return t;      
}

byte ValHex(char c1, char c2)
{
  return Val(c2) + 16 * Val(c1); 
}

void loop()
{  
  byte randRed;
  byte randGreen;
  byte randBlue;
  randRed = random(0,2);
  randGreen = random(0,2);
  randBlue = random(0,2);
  
  int i = 0;
  for (i=0; i<5; i++) {
      delay(50);
      if ( randRed == 1 ) {
        if ( Red < 255 ) {
          Red++;
        }
      } else {
        if ( Red > 0 ) {
          Red--;
        }
      }
      if (randGreen == 1) {
        if ( Green < 255 ) {
          Green++;
        }
      } else {
        if ( Green > 0 ) {
          Green--;
        }
      }
      if (randBlue == 1) {
        if ( Blue < 255 ) {
          Blue++;
        }
      } else {
        if ( Blue > 0 ) {
          Blue--;
        }
      }
  
      livcol.setLampColourHSV(0, Red, Green, Blue);
  }
}


