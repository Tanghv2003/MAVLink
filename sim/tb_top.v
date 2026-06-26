`timescale 1ns/1ps

module tb_top();

    reg clk, reset, rx;

    always #5 clk = ~clk;  

    initial begin
        clk   = 0;
        reset = 1;
        rx    = 1;
        #100;
        reset = 0;
        #100;

        mavlink();
        repeat(500) @(posedge tick_mon);

        mavlink();
        repeat(500) @(posedge tick_mon);

        mavlink();
        repeat(500) @(posedge tick_mon);

        #5_000_000;
        $display("End simulation");
        $stop;
    end

    top_rx dut (
        .clk  (clk),
        .reset(reset),
        .rx   (rx)
    );

    wire tick_mon = dut.tick;

    
    task uart_send_byte;
        input [7:0] tx_data;
        integer i;
        begin
           
            rx = 0;
            repeat(16) @(posedge tick_mon);
            
            for (i = 0; i < 8; i = i + 1) begin
                rx = tx_data[i];
                repeat(16) @(posedge tick_mon);
            end
            
            rx = 1;
            repeat(16) @(posedge tick_mon);
        end
    endtask

    
    task mavlink;
        begin
           
            uart_send_byte(8'hFD);  
            uart_send_byte(8'h13);  
            uart_send_byte(8'h00);  
            uart_send_byte(8'h00);  
            uart_send_byte(8'h00);  
            uart_send_byte(8'h01);  
            uart_send_byte(8'h01);  
            uart_send_byte(8'hFD);  
            uart_send_byte(8'h00);  
            uart_send_byte(8'h00);  
            
            uart_send_byte(8'h06);  
            uart_send_byte(8'h48);  
            uart_send_byte(8'h65);  
            uart_send_byte(8'h6C);  
            uart_send_byte(8'h6C);  
            uart_send_byte(8'h6F);  
            uart_send_byte(8'h20);  
            uart_send_byte(8'h66);  
            uart_send_byte(8'h72);  
            uart_send_byte(8'h6F);  
            uart_send_byte(8'h6D); 
            uart_send_byte(8'h20);  
            uart_send_byte(8'h50);  
            uart_send_byte(8'h79);  
            uart_send_byte(8'h74);  
            uart_send_byte(8'h68);  
            uart_send_byte(8'h6F);  
            uart_send_byte(8'h6E);  
            uart_send_byte(8'h21);  
            
            uart_send_byte(8'h5D);
            uart_send_byte(8'hAD);
            
        end
    endtask

endmodule