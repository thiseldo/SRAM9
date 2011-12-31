/**
  Author:  Marcus Hund aka: Marko Hiero. 
  Sources: SRAM library written by Carl Morey. 
           SRAM9 partly by Carl Morey and parts by Marcus Hund
           Ethernet Library by David A. Mellis.
           
  
  Description: This project tests the 32k256 SRAM and the Ethershield. 
  Hardware information: To make both work in a project the following changes and connections have to be made: 
  32k256 SRAM: 
   digital pin 13    SCK
   digital pin 12    MISO
   digital pin 11    MOSI
   digital pin  9    SS, the orignal SRAM lib uses pin 10. But this pin is also used by the Ethershield
                     To make it work change the following code in the SRAM.h file: 0x04 to 0x02 at line
                     28 and 29. (Or use the SRAM9 lib.) 
   Ethershield: Old version: connect pin2 of the prog connector on the Ethershield to digital I/O 9.
                New version (version 5) change nothing.
  
  
  The original ethershield does not disconnect the W5100 SPI interface completely from the SPI bus when SS is turned low. Therefor
  it is necessairy to add a connection from pin 2 of the prog connector on the Ethershield to 
  digital I/O 9. This pin is also used to select the 32k256 SRAM. When pin 9 is HIGH the 
  Ethershield is enabled, when it is low the SRAM is enabled. 

**/
#include <SPI.h>
#include <Client.h>
#include <Ethernet.h>
#include <Server.h>
#include <Udp.h>
#include <SRAM9.h>

byte mac[] = {  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,1,177 };
byte server[] = { 85,17,185,46  }; // wouterh.nl

Client client(server, 80);

void setup()
{ 
  Ethernet.begin(mac, ip);
  Serial.begin(9600);   // initialize serial communications
  Serial.println("connecting...");
 
  Serial.println(SPCR,BIN);
 
}//end of setup

void loop()
{
  testram();
  delay(1000);
  do_client();
  //Serial.println(SPCR,BIN);
}//end of loop

void testram()
{
  SRAM9.writestream(0);  // start address from 0
  unsigned long stopwatch = millis(); //start stopwatch

  for(unsigned int i = 0; i < 32768; i++)
    SRAM9.RWdata(0x55); //write to every SRAM address 

  Serial.print(millis() - stopwatch);
  Serial.println("   ms to write full SRAM");

  SRAM9.readstream(0);   // start address from 0 

  for(unsigned int i = 0; i < 32768; i++)
  {
    if(SRAM9.RWdata(0xFF) != 0x55)  //check every address in the SRAM
    {
      Serial.println("error in location  ");
      Serial.println(i);
      break;
    }//end of print error
    if(i == 32767)
      Serial.println("no errors in the 32768 bytes");
  }//end of get byte
  SRAM9.closeRWstream();
}


void do_client(){
  
  if (client.connect()) {
    Serial.println("connected");
    // Make a HTTP request:
    client.println("GET /search?q=arduino HTTP/1.0");
    client.println();
  } 
  else {
    // kf you didn't get a connection to the server:
    Serial.println("connection failed");
  }
  delay (2000);
  if (client.available()) {
     while(client.available()){
        char c = client.read();
        Serial.print(c);
     }
  }

  // if the server's disconnected, stop the client:
  if (!client.connected()) {
    Serial.println();
    Serial.println("disconnecting.");
    client.stop();
  } 
  
}

