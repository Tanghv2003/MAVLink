`timescale 1ns/1ps
module tb_uart();
    reg clk, reset;
    reg tx_start;
    reg [7:0] din;
    wire tx_done_tick;
    wire tx;

    initial begin
        clk = 0;
        baud_cnt = 0;
    end

    always #5 clk = ~clk;
    //localparam integer BAUD_DIV = CLK_HZ / (BAUD * 16);
    localparam integer BAUD_DIV = 115200;
    reg [$clog2(BAUD_DIV)-1:0] baud_cnt;
    reg s_tick;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            baud_cnt <= 0;
            s_tick   <= 0;
        end else begin
            s_tick <= 0;
            if (baud_cnt == BAUD_DIV - 1) begin
                baud_cnt <= 0;
                s_tick   <= 1;
            end else
                baud_cnt <= baud_cnt + 1;
        end
    end

    uart_tx tx_inst(
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .din(din),
        .tick(s_tick),
        .tx_done_tick(tx_done_tick),
        .tx(tx)
    );

    initial begin
        reset = 1;
        #20;
        reset = 0;
        #30;
        tx_start = 1;
        din = 8'hAA;

        // @ (posedge clk);
        // tx_start = 0;
        // @ (posedge clk);
        // tx_start = 1;
        // din = 8'hAB;

        // @ (posedge clk);
        // tx_start = 0;
        // @ (posedge clk);
        // tx_start = 1;
        // din = 8'hAC;

        // @ (posedge clk);
        // tx_start = 0;
        // @ (posedge clk);
        // tx_start = 1;
        // din = 8'hAD;

        //  @ (posedge clk);
        // tx_start = 0;
        wait(tx_done_tick);
        @ (posedge clk);
        @ (posedge clk);
        @ (posedge clk);
        @ (posedge clk);
        $stop;
    end
endmodule