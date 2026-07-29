#include <stdio.h>
#include <string.h>
#include "system.h"
#include "tx.h"


void tx_write(int addr, int value)
{
    *(volatile int *)(TX_0_BASE + addr) = value;
}


bool wait_done()
{
    return (*(volatile int *)(TX_0_BASE + ADDR_BUSY_REG)) & 0x01;
}


bool is_full()
{
    return (*(volatile int *)(TX_0_BASE + ADDR_FIFO_FULL)) & 0x01;
}


void send_frame(char *payload, int len,
                int sys_id, int comp_id,
                int msg_id,
                int inc_flags, int cmp_flags)
{
    while (wait_done());

    if (!is_full())
    {
        tx_write(ADDR_PAYLOAD_LEN, len);
        tx_write(ADDR_INC_FLAGS, inc_flags);
        tx_write(ADDR_COM_FLAGS, cmp_flags);
        tx_write(ADDR_SYSID, sys_id);
        tx_write(ADDR_COMPID, comp_id);
        tx_write(ADDR_MSGID, msg_id & 0x00FFFFFF);

        for (int i = 0; i < len; i++)
        {
            tx_write(ADDR_FIFO, payload[i]);
        }

        tx_write(ADDR_START, 1);

        while (wait_done());
    }
}


void send_heartbeat(void)
{
    char p[9] = {
        0x00, 0x00, 0x00, 0x00,
        0x06, 0x08, 0xC1, 0x04, 0x03
    };

    send_frame(p, 9, 1, 1, 0, 0x00, 0x00);
}


void send_statusText(char *payload)
{
    char p[51];
    memset(p, 0, sizeof(p));

    p[0] = 0; // security byte

    int len = strlen(payload);
    memcpy(p + 1, payload, len);

    send_frame(p, 51, 1, 1, 253, 0x00, 0x00);
}


void sendText()
{
    char input[255];
    memset(input, 0, sizeof(input));
    char c;
    int i;
    for (i = 0; i < 254; i++)
    {
        scanf("%c", &c);
        if (c == '\n' || c == '\r')
            break;
        input[i] = c;
    }
    input[i] = '\0';
    if (i > 0)
    {
        send_statusText(input);
        printf("Da gui: %s\n", input);
    }
}
