#include <Servo.h>

int p_motor_left_speed = 3;
int p_motor_left_1 = 1;
int p_motor_left_2 = 2;

int p_motor_right_speed = 26;
int p_motor_right_1 = 27;
int p_motor_right_2 = 28;

Servo servolf;
Servo servorf;
Servo servolb;
Servo servorb;
/*
  Blink
  Turns on an LED on for one second, then off for one second, repeatedly.
 
  This example code is in the public domain.
 */

void setup() {               
  // initialize the digital pin as an output.
  // Pin 13 has an LED connected on most Arduino boards:
  /*pinMode(13, OUTPUT);
 
  pinMode(11, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(9, OUTPUT);
  pinMode(8, OUTPUT);*/
 
  //pinMode(0, OUTPUT);
  //pinMode(1, OUTPUT);
  
  // Setup motors
  // setup motor 1eft
  pinMode(p_motor_left_speed, OUTPUT);
  pinMode(p_motor_left_1, OUTPUT);
  pinMode(p_motor_left_2, OUTPUT);
  
  // setup motor right
  pinMode(p_motor_right_speed, OUTPUT);
  pinMode(p_motor_right_1, OUTPUT);
  pinMode(p_motor_right_2, OUTPUT);
  
  // Setup servos
 
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(6, OUTPUT);
  pinMode(7, OUTPUT);
  
  servolf.attach(4);
  servorf.attach(5);
  servolb.attach(6);
  servorb.attach(7);
}

void demo_servos() {
  sit();
  delay(1000);
  stand();  
  delay(1000);
  f_sit();
  delay(1000);
  b_sit();
  delay(1000);
  l_stand();
  delay(1000);
  r_stand();
  delay(1000);
}

void demo_wheels() {
  motor_left_speed(255);
  motor_left_forward();
  delay(4000);
  //motor_left_stop();
  //delay(1000);
  
  motor_left_speed(200);
  motor_left_forward();
  delay(4000);
  //motor_left_stop();
  //delay(1000);
  
  //motor_left_speed(255);
  //delay(8000);
  //motor_left_speed(120);
  //delay(4000);
  //motor_left_speed(0);
  //delay(4000);
  //motor_left_speed(100);
}

void loop() {
  // Play with wheels
  //demo_wheels();

  // Play with servos
  demo_servos();
  
  // initial position
  //sit();
  //delay(4000);
  //stand();
  //delay(4000);
}

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

/**
 * Set left motor speed: 0-255.
 */
void motor_left_speed(int mspeed) {
  analogWrite(p_motor_left_speed, mspeed);
}

void motor_left_forward() {
  delay(30);
  digitalWrite(p_motor_left_1, 1);
  digitalWrite(p_motor_left_2, 0);
  delay(30);
}

void motor_left_backward() {
  delay(30);
  digitalWrite(p_motor_left_1, 0);
  digitalWrite(p_motor_left_2, 1);
  delay(30);
}

void motor_left_stop() {
  delay(30);
  digitalWrite(p_motor_left_1, 0);
  digitalWrite(p_motor_left_2, 0);
  delay(30);
}

/**
 * Set left motor speed: 0-255.
 */
void motor_right_speed(int mspeed) {
  delay(30);
  analogWrite(p_motor_right_speed, mspeed);
  delay(30);
}

