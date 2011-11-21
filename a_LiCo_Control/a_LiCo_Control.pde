#include <CC2500.h>
#include <ColourConversion.h>
#include <LivingColors.h>

#define MOSI   11    // SPI master data out pin
#define MISO   12    // SPI master data in pin
#define SCK    13    // SPI clock pin
#define CS     10    // SPI slave select pin

LivingColors livcol(CS, SCK, MOSI, MISO);

//unsigned char lamp[9] = { 0xDF, 0xF0, 0xE5, 0x27, 0x49, 0x5D, 0x9C, 0x8B, 0x11 }; // Lamp George
unsigned char lamp1[9] = { 0x7C, 0xB1, 0xE8, 0x4E, 0x27, 0x3B, 0xDC, 0x1D, 0x11 }; // Lamp Ivo
//unsigned char lamp1[9] = { 0xE4, 0x69, 0x00, 0x21, 0x89, 0x56, 0xF7, 0x6F, 0x11 }; // Lamp woonkamer
//unsigned char lamp2[9] = { 0x4F, 0x1F, 0xB7, 0x85, 0xE5, 0x36, 0x31, 0xA9, 0x11 }; // dummy lamp
unsigned char adress[9] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
int red = 255;
int green = 1;
int blue = 1;
unsigned int i = 0;
boolean lampOn = false;
boolean echo = false;
unsigned int t = 0;

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
    //livcol.addLamp(lamp2);
    
    Serial.println("!");
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
  { SerBuf[i]=0; }
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
      case 'a' : case 'A' : t = 10;
      case 'b' : case 'B' : t = 11;
      case 'c' : case 'C' : t = 12;
      case 'd' : case 'D' : t = 13;
      case 'e' : case 'E' : t = 14;
      case 'f' : case 'F' : t = 15;
    }    
  return t;      
}

byte ValHex(char c1, char c2)
{
  return Val(c2) + 16 * Val(c1); 
}

void loop()
{
  byte valA;
  byte valB;
  byte valC;
  byte valD;
  ReadLine();
  switch (SerBuf[0])
  {
    case 'q' :
    {
      Serial.println("-- valid commands are :");
      Serial.println("q : this help screen");
      Serial.println("r : reset");
      Serial.println("wl-rrr-ggg-bbb : r, g and b are numbers 000 to 255. Example \"w000-255-000\" for bright green.");
      Serial.println("hl-hhh-sss-iii : h, s and i are numbers 000 to 255. No example for now..");
      Serial.println("i : print info");
      Serial.println("annn : select lamp n. Example \"a001\" to select lamp 1.");
      Serial.println("nl-rrr-ggg-bbb : turn lamp on");      
      Serial.println("fl : turn lamp off");      
      Serial.println("ee : e = 0 echo off, e = 1 echo on.");
      Serial.println("l : listen for adresses. Use I to list adresses.");
      Serial.println("saabbccddeeffgghhii : store adress in a..i. 9 numbers as 2 digit hex");
      Serial.println("? : dummy command.");
      Serial.println("");
      Serial.println("a response of \"?\" means invalid command. \"!\" means command executed."); 
      Serial.println("!");
      break;
    }
    case 'r' :
    {
      livcol.init();
      Serial.println("!");
      break;
    }
    case 'w' :
    {
      valA = Val(SerBuf[1]);
      valB = Val(SerBuf[3],SerBuf[4],SerBuf[5]);
      valC = Val(SerBuf[7],SerBuf[8],SerBuf[9]);
      valD = Val(SerBuf[11],SerBuf[12],SerBuf[13]);    
      livcol.setLampColourRGB(valA, valB, valC, valD);
      Serial.println("!");
      break;
    }   
    case 'h' :
    {
      valA = Val(SerBuf[1]);
      valB = Val(SerBuf[3],SerBuf[4],SerBuf[5]);
      valC = Val(SerBuf[7],SerBuf[8],SerBuf[9]);
      valD = Val(SerBuf[11],SerBuf[12],SerBuf[13]);    
      livcol.setLampColourHSV(valA, valB, valC, valD);
      Serial.println("!");
      break;
    }    
    case 'i' :
    {
      if (echo)
        Serial.println("echo on");
      else
        Serial.println("echo off");
      Serial.print(livcol.getNumLamps(), HEX);
      Serial.println(" lamps");
      PrintAdress();     
      Serial.println("!");
      break;
    }
    case 'l' :
    {
      livcol.learnLamps();
      Serial.println("!");
      break;
    }
    case 'n' :
    {
      valA = Val(SerBuf[1]);
      valB = Val(SerBuf[3],SerBuf[4],SerBuf[5]);
      valC = Val(SerBuf[7],SerBuf[8],SerBuf[9]);
      valD = Val(SerBuf[11],SerBuf[12],SerBuf[13]); 
      livcol.turnLampOnRGB(valA,valB,valC,valD);
      delay(10);
      Serial.println("!");
      break;
    }
    case 'f' :
    {
      valA = Val(SerBuf[1]);      
      livcol.turnLampOff(valA);
      lampOn = false;
      Serial.println("!");
      break;
    }
    case 'e' :
    {
      valA = Val(SerBuf[1]);
      if (valA==0)
         echo = false;
      if (valA==1)
         echo = true;   
      Serial.println("!");   
      break;
    }
    case 's' :
    {
      adress[0] = ValHex(SerBuf[1],SerBuf[2]);
      adress[1] = ValHex(SerBuf[3],SerBuf[4]);
      adress[2] = ValHex(SerBuf[5],SerBuf[6]);
      adress[3] = ValHex(SerBuf[7],SerBuf[8]);
      adress[4] = ValHex(SerBuf[9],SerBuf[10]);
      adress[5] = ValHex(SerBuf[11],SerBuf[12]);
      adress[6] = ValHex(SerBuf[13],SerBuf[14]);
      adress[7] = ValHex(SerBuf[15],SerBuf[16]);
      adress[8] = ValHex(SerBuf[17],SerBuf[18]);
      adress[9] = ValHex(SerBuf[19],SerBuf[20]);
      int n = livcol.addLamp(adress);      
      Serial.println(n, DEC);
      Serial.println("!");
      break;
    }
    case '?' :
    {
      Serial.println("!");
      break;
    }
    default :
    {
      Serial.println("?");
      break;
    }
  }
}

