#include "system.h"
#include "uart.h"

int rx_read(int addr){
	return *(int*) (RX_0_BASE + addr * 4);
}
void rx_write(int addr, int value){
	*(int*)(RX_0_BASE + addr*4) = value;
}
int rx_busy(){
	return rx_read(REG_BUSY) & 0x01;
}
int fifo_Empty(){
	return rx_read(REG_FIFO_EMPTY) & 0x01;
}

int fifo_Full(){
	return rx_read(REG_FIFO_FULL) & 0x01;
}
