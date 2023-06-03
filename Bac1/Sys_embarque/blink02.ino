#include <Tempo.h>

#define lPin 13

Tempo t1(1000, DELAY_ON);

void setup()
{
  pinMode(lPin, OUTPUT);
  t1.restart();
}

void loop()
{
  if (t1.ison()) {
      digitalWrite(lPin, !digitalRead(lPin));
      t1.restart();
  }
}
  
