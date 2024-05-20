#include <ArduinoJson.h>
#define Button 4
#define led_R 11
#define led_G 10
#define led_B 9
DynamicJsonDocument doc(80);
long  duration=0;
long  temp=0;
byte RGB[3]={0,0,0};
bool shouldWaitForMotion =false;
bool isOn =false;
bool infinity =true;
bool sync =false;
bool Updated =false;
char ch;
void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
 pinMode(led_R,OUTPUT);
 pinMode(led_G,OUTPUT);
 pinMode(led_B,OUTPUT);
   pinMode(Button,INPUT_PULLUP);
   temp=millis();
}

void loop() {
 
 if(Serial.available()>0){
String res ="";
sync =true;

while (sync){
  if(Serial.available()>0){
    ch=char(Serial.read());
    if(ch==';'){
      sync =false;
    }else{
      res+=ch;
    }
    
  }
  
  
}
  DeserializationError error = deserializeJson(doc, res);
  
   if (error) {
  }else{
    if(doc["duration"].isNull()){
     duration=0;
     infinity =true;
    }else{
      int hours =doc["duration"]["hours"] ;
      int minutes=doc["duration"]["minutes"];
      int seconds=doc["duration"]["seconds"];
      duration= (hours *3600 +minutes *60 +seconds );
      duration=duration*1000;
     infinity =false;
    }
    shouldWaitForMotion=doc["shouldWaitForMotion"];
    isOn =doc["isOn"];
     parseHexString(doc["color"], RGB);
     temp=millis();
     Updated =false;
  }
  
 }
 if(!infinity && (duration<=millis()-temp)){
  Serial.print("0");
  infinity =true;
 }
 if((!digitalRead(Button)||!shouldWaitForMotion)){
 if(isOn){
   analogWrite(led_R,RGB[0]);
   analogWrite(led_G,RGB[1]);
   analogWrite(led_B,RGB[2]);
 }else{
     analogWrite(led_R,0);
   analogWrite(led_G,0);
   analogWrite(led_B,0);
 }
 }
 if((!digitalRead(Button) && shouldWaitForMotion && !Updated)){
  Serial.print("1");
  Updated =true;

 }

}
void parseHexString(String hexString, byte* byteArray) {
  for (int i = 1; i < hexString.length(); i += 2) {
    byteArray[i / 2] = strtoul(hexString.substring(i, i + 2).c_str(), NULL, 16);
  }
}