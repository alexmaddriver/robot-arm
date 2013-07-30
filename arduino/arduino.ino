
#include <Servo.h>

const int Q1_PIN = 5;
const int Q2_PIN = 6;

Servo q1Servo;
Servo q2Servo;

String pendingCommands = "";

void setup()
{
  Serial.begin(9600);
  
  q1Servo.attach(Q1_PIN);   
  q2Servo.attach(Q2_PIN);   
}
 
void loop()
{
  String command = readNextCommand();
  if (command.length() > 0)
    actuateArm(command);
}

String readNextCommand()
{
  readCommandsFromSerial();

  String command;
  int commandSeparatorIndex = pendingCommands.indexOf(';');
  if (commandSeparatorIndex != -1)
  {
    command = pendingCommands.substring(0, commandSeparatorIndex); 
    pendingCommands = (pendingCommands.length() > commandSeparatorIndex) ? pendingCommands.substring(commandSeparatorIndex+1) : "";
  }
  return command;
}

void readCommandsFromSerial() 
{
  while (Serial.available() > 0) 
  {
    char ch = Serial.read();
    pendingCommands += ch;
  }
}

void actuateArm(String command)
{
  int semicolonIndex = command.indexOf(':');
  int q1 = command.substring(0, semicolonIndex).toInt();
  int q2 = command.substring(semicolonIndex+1).toInt();
  
  if (true)
  {
    Serial.print("q1=");
    Serial.print(q1);
    Serial.print(", q2=");
    Serial.print(q2); 
    Serial.println("");
  }
  
  q1Servo.write(q1);
  q2Servo.write(q2);
  delay(15);
}

