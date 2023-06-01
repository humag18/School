# Arduino

#Code EX1

Pour cet Ex il faut connecter 2 boutons et 2 leds chacun des boutons gère une seule led
>Relier le coté le plus grand (+) à un port de l'Arduino le plus petit (-) à la ligne négative de la breadboard.
Pour les boutons, relier une des deux partie à ligne des négatif et l'autre à l'un des ports de l'Arduino

```C++
# define LEDR 13
# define LEDG 12
# define BP1 2
# define BP2 1
void setup()
{
  pinMode(BP1,INPUT_PULLUP);
  pinMode(LEDR,OUTPUT);
  pinMode(BP2,INPUT_PULLUP);
  pinMode(LEDG,OUTPUT);
}

void loop()
{
  boolean etat1 = digitalRead(BP1);
  if(etat1==LOW){
    digitalWrite(LEDR,HIGH);
  }
  else
    digitalWrite(LEDR,LOW);
  boolean etat2 = digitalRead(BP2);
  if(etat2==LOW){
    digitalWrite(LEDG,HIGH);
  }
  else
    digitalWrite(LEDG,LOW);
}
```
