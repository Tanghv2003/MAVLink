# pragma once
#define EMPTY_REG 0x10A
#define FULL_REG 0x10B
#define BUSY_REG 0x10C

int rx_read(int addr);
void rx_write(int addr, int value);

int fifo_Empty();
int fifo_Full();
int busy();
void readFrame();
