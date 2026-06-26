`timescale 1ns/1ps

module tb_uart_rx();

    reg clk;
    reg reset;
    reg rx;

    wire tick;
    wire rx_done_tick;
    wire [7:0] dout;


    baudrate_gen baudrate_gen_inst(
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    uart_rx uart_rx_inst(
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .rx(rx),
        .rx_done_tick(rx_done_tick),
        .dout(dout)
    );

    

    always #5 clk = ~clk;

    

    task uart_send_byte;
        input [7:0] tx_data;
        integer i;
        begin

            // idle
            rx = 1;
            repeat(16) @(posedge tick);

            // start
            rx = 0;
            repeat(16) @(posedge tick);

            // data
            for(i=0; i<8; i=i+1) begin
                rx = tx_data[i];
                repeat(16) @(posedge tick);
            end

            // stop
            rx = 1;
            repeat(16) @(posedge tick);

        end
    endtask

    

    initial begin

        clk   = 0;
        reset = 1;
        rx    = 1;

        #150;
        reset = 0;


        uart_send_byte(8'h41); 
        uart_send_byte(8'h42); 
        uart_send_byte(8'h43);
        uart_send_byte(8'hFD);

        repeat(50) @(posedge clk);

        
        $display("\n\t END SIMULATION");
        

        $stop;
    end

endmodule