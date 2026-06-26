`timescale 1ns/1ps

module tb_test2();

    reg clk;
    reg reset;

    reg [8:0]  address;
    reg        read;
    reg        write;
    reg [31:0] writedata;

    wire [31:0] readdata;
    wire        readdataValid;

    reg rx;
    wire tick;

    avalon_slave_rx a_rx(
        .clk(clk),
        .reset(reset),
        .address(address),
        .read(read),
        .write(write),
        .writedata(writedata),
        .readdata(readdata),
        .readdataValid(readdataValid),
        .tick(tick),
        .rx(rx)
    );

    baudrate_gen #(
    .BAUD_RATE(9600),
    .f(100_000_000)
    ) baud_inst(
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    initial begin
        clk       = 0;
        reset     = 1;
        address   = 9'h0;
        read      = 0;
        write     = 0;
        writedata = 32'h0;
        rx        = 1;
    end

    always #5 clk = ~clk;

    task uart_send_byte;
        input [7:0] tx_data;
        integer i;
        begin
            rx = 1;
            repeat(16) @(posedge tick);

            // start bit
            rx = 0;
            repeat(16) @(posedge tick);

            // data bit
            for (i = 0; i < 8; i = i + 1) begin
                rx = tx_data[i];
                repeat(16) @(posedge tick);
            end

            // stop bit
            rx = 1;
            repeat(16) @(posedge tick);
        end
    endtask

    initial begin
        #100;
        reset = 0;
        #100;

        
        $display("fd 13 00 00 00 01 01 fd 00 00 | 06 48 65 6c 6c 6f 20 66 72 6f 6d 20 50 79 74 68 6f 6e 21 | 5d ad");

        
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
        #100000;

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


        #100000;

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

        
        $display("done\n\n");
        

        #10000000;
        $display("\n\tEnd simulation");
        $stop;
    end

endmodule