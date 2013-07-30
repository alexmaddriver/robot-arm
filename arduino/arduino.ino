
const int Q1_PIN = 5;
const int Q2_PIN = 6;

String pendingCommands = "";

void setup()
{
  Serial.begin(9600);
  
  pinMode(Q1_PIN, OUTPUT);   
  pinMode(Q2_PIN, OUTPUT);   
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
  
  Serial.print("q1=");
  Serial.print(q1);
  Serial.print(", q2=");
  Serial.print(q2); 
  Serial.println("");
}

