#include <WiFiShieldOrPmodWiFi_G.h>

#include <DNETcK.h>
#include <DWIFIcK.h>

// wheels
const int LEFT_MOTOR_F_PIN = 8;
const int LEFT_MOTOR_B_PIN = 9;
const int RIGHT_MOTOR_F_PIN = 39;
const int RIGHT_MOTOR_B_PIN = 40;


// legs
#include <Servo.h>

const int SERVO_LF_PIN = 4;
const int SERVO_RF_PIN = 5;
const int SERVO_LB_PIN = 6;
const int SERVO_RB_PIN = 7;

Servo servolf;
Servo servorf;
Servo servolb;
Servo servorb;

// WiFi
IPv4 ipServer = {192,168,43,191};
unsigned short portServer = DNETcK::iPersonalPorts44 + 300;

const char * szSsid = "lasto4ka";

#define WiFiConnectMacro() DWIFIcK::connect(szSsid, &status)

typedef enum
{
    NONE = 0,
    INITIALIZE,
    LISTEN,
    ISLISTENING,
    AVAILABLECLIENT,
    ACCEPTCLIENT,
    READ,
    WRITE,
    CLOSE,
    EXIT,
    DONE
} STATE;

STATE state = INITIALIZE;

unsigned tStart = 0;
// connection reset timeout
unsigned tWait = 10000;

TcpServer tcpServer;
TcpClient tcpClient;

byte rgbRead[1024];
int cbRead = 0;
int count = 0;

DNETcK::STATUS status;

/* ***************************************************** */
// Wheels

void runLeftMotorF() {
  digitalWrite(LEFT_MOTOR_F_PIN, HIGH);
}
void runRightMotorF() {
  digitalWrite(RIGHT_MOTOR_F_PIN, HIGH);
}
void runLeftMotorB() {
  digitalWrite(LEFT_MOTOR_B_PIN, HIGH);
}
void runRightMotorB() {
  digitalWrite(RIGHT_MOTOR_B_PIN, HIGH);
}
void stopLeftMotor() {
  digitalWrite(LEFT_MOTOR_F_PIN, LOW);
  digitalWrite(LEFT_MOTOR_B_PIN, LOW);
}
void stopRightMotor() {
  digitalWrite(RIGHT_MOTOR_F_PIN, LOW);
  digitalWrite(RIGHT_MOTOR_B_PIN, LOW);
}

void stopMotors() {
  stopLeftMotor();
  stopRightMotor();
}

void moveForward() {
  stopMotors();
  runLeftMotorF();
  runRightMotorF();
}
void moveBack() {
  stopMotors();
  runLeftMotorB();
  runRightMotorB();
}
void moveLeft() {
  stopMotors();
  runLeftMotorB();
  runRightMotorF();
}
void moveRight() {
  stopMotors();
  runLeftMotorF();
  runRightMotorB();  
}

/* ***************************************************** */
// Legs

void f_sit() {
  servolf.write(0);
  servorf.write(180);
}

void f_stand() {
  servolf.write(50);
  servorf.write(130);
}

void b_sit() {
  servolb.write(180);
  servorb.write(0);
}

void b_stand() {
  servolb.write(130);
  servorb.write(50);
}

void l_sit() {
  servolf.write(0);
  servolb.write(180);
}

void l_stand() {
  servolf.write(50);
  servolb.write(130);
}

void r_sit() {
  servorf.write(180);
  servorb.write(0);
}

void r_stand() {
  servorf.write(130);
  servorb.write(50);
}


void sit() {
  f_sit();
  b_sit();
}

void stand() {
  f_stand();
  b_stand();
}

/* ***************************************************** */
// Runtime

void printIP(void)
{
  Serial.print("IP Address assigned: ");
  Serial.print((int)ipServer.rgbIP[0]);
  Serial.print(".");
  Serial.print((int)ipServer.rgbIP[1]);
  Serial.print(".");
  Serial.print((int)ipServer.rgbIP[2]);
  Serial.print(".");
  Serial.println((int)ipServer.rgbIP[3]);
}
void setup() {

    // Wheels
    pinMode(LEFT_MOTOR_F_PIN, OUTPUT);
    pinMode(LEFT_MOTOR_B_PIN, OUTPUT);
    pinMode(RIGHT_MOTOR_B_PIN, OUTPUT);
    pinMode(RIGHT_MOTOR_F_PIN, OUTPUT);

    
    digitalWrite(LEFT_MOTOR_F_PIN, LOW);
    digitalWrite(LEFT_MOTOR_B_PIN, LOW);
    digitalWrite(RIGHT_MOTOR_B_PIN, LOW);
    digitalWrite(RIGHT_MOTOR_F_PIN, LOW);
    
    // Legs
    pinMode(SERVO_LF_PIN, OUTPUT);
    pinMode(SERVO_RF_PIN, OUTPUT);
    pinMode(SERVO_LB_PIN, OUTPUT);
    pinMode(SERVO_RB_PIN, OUTPUT);
  
    servolf.attach(SERVO_LF_PIN);
    servorf.attach(SERVO_RF_PIN);
    servolb.attach(SERVO_LB_PIN);
    servorb.attach(SERVO_RB_PIN);
    
    // sit by default
    stand();
    
    // Wifi
    int conID = DWIFIcK::INVALID_CONNECTION_ID;

    Serial.begin(9600);
    Serial.println("WiFiTCPEchoServer 1.0");
    Serial.println("Digilent, Copyright 2012");
    Serial.println("");

    if((conID = WiFiConnectMacro()) != DWIFIcK::INVALID_CONNECTION_ID)
    {
        Serial.print("Connection Created, ConID = ");
        Serial.println(conID, DEC);
        printIP();
        state = INITIALIZE;
    }
    else
    {
        Serial.print("Unable to connection, status: ");
        Serial.println(status, DEC);
        state = EXIT;
    }

    DNETcK::begin(ipServer);
      
}

void loop() {
  
    switch(state)
    {

    case INITIALIZE:
        if(DNETcK::isInitialized(&status))
        {
            Serial.println("IP Stack Initialized");
            state = LISTEN;
        }
        else if(DNETcK::isStatusAnError(status))
        {
            Serial.print("Error in initializing, status: ");
            Serial.println(status, DEC);
            state = EXIT;
        }
        break;

    case LISTEN:
        if(tcpServer.startListening(portServer))
        {
            Serial.println("Started Listening");
            state = ISLISTENING;   
            
        }
        else
        {
            state = EXIT;
        }
        break;

    case ISLISTENING:
        if(tcpServer.isListening(&status))
        {  
            Serial.print("Listening on port: ");
            Serial.print(portServer, DEC);
            Serial.println("");
            
            state = AVAILABLECLIENT;
        }
        else if(DNETcK::isStatusAnError(status))
        {
            state = EXIT;
        }
        break;

    case AVAILABLECLIENT:
        if((count = tcpServer.availableClients()) > 0)
        {
            Serial.print("Got ");
            Serial.print(count, DEC);
            Serial.println(" clients pending");
            state = ACCEPTCLIENT;
        }
        break;

    case ACCEPTCLIENT:
        
        tcpClient.close(); 

        if(tcpServer.acceptClient(&tcpClient))
        {
            Serial.println("Got a Connection");
            state = READ;
            tStart = (unsigned) millis();
        }

        else
        {
            state = CLOSE;
        }
        break;

    case READ:

        if((cbRead = tcpClient.available()) > 0)
        {
            cbRead = cbRead < sizeof(rgbRead) ? cbRead : sizeof(rgbRead);
            cbRead = tcpClient.readStream(rgbRead, cbRead);

            Serial.print("Got ");
            Serial.print(cbRead, DEC);
            Serial.println(" bytes");

	    switch(rgbRead[cbRead-1]){
              // wheels 
              case 'F': moveForward(); break;
              case 'B': moveBack(); break;
              case 'L': moveLeft(); break;
              case 'R': moveRight(); break;
              case 'S': stopMotors(); break;
              
              // legs
              case 'A': f_stand(); break; // "FU"
              case 'T': f_sit(); break; // "FD"
              case 'U': b_stand(); break; // "BU"
              case 'V': b_sit(); break; // "BD"
              case 'W': l_stand(); break; // "LU"
              case 'X': l_sit(); break; // "LD"
              case 'Y': r_stand(); break; // "RU"
              case 'Z': r_sit(); break; // "RD"
            }
           
            state = WRITE;
        }

        else if( (((unsigned) millis()) - tStart) > tWait )
        {
            state = CLOSE;
        }
        break;

    case WRITE:
        if(tcpClient.isConnected())
        {               
            Serial.println("Writing: ");  
            for(int i=0; i < cbRead; i++) 
            {
                Serial.print(rgbRead[i], BYTE);
            }
            Serial.println("");  

            tcpClient.writeStream(rgbRead, cbRead);
            state = READ;
            tStart = (unsigned) millis();
        }

        else
        {
            Serial.println("Unable to write back.");  
            state = CLOSE;
        }
        break;
        
    case CLOSE:
        tcpClient.close();
        Serial.println("Closing TcpClient");
        Serial.println("");
        stopMotors();
        state = ISLISTENING;
        break;

    case EXIT:
        tcpClient.close();
        tcpServer.close();
        Serial.println("Something went wrong, sketch is done.");  
        stopMotors();
        state = DONE;
        break;

    case DONE:
    default:
        break;
    }
    
    DNETcK::periodicTasks(); 
}

