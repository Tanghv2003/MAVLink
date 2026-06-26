#include <stdio.h>
#include "rx.h"
#include "led.h"
void delay(int v){
	while(v--);
}
int main(){
	Frame frame;
	while(1){
		readFrame(&frame);
		delay(100000);
	}
}
