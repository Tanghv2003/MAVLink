

#include <stdio.h>
#include "system.h"
#include "rx.h"
void delay(int v){
	while(v--);
}
int main()
{
  printf("\n---------------------------\n");
  Frame frame;
  while(1){
      readFrame(&frame);
      //delay(200000);
      //delay(500000);
  }
  return 0;
}
