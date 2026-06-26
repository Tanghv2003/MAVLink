`timescale 1ns / 1ps

module tb_test1();
    reg clk,reset;
    reg [8:0] address;
    reg read,write;
    reg [31:0] writedata;
    wire [31:0] readdata;
    wire readdataValid;

    avalon_slave_tx uut(
        .clk(clk),
        .reset(reset),
        .address(address),
        .read(read),
        .write(write),
        .readdata(readdata),
        .writedata(writedata),
        .readdataValid(readdataValid)
    );

    initial begin
        clk = 0;
        reset = 1;
        address = 0;
        read = 0;
        write = 0;
        writedata = 0;
    end

    always #5 clk = ~clk;

    initial begin
   
    #20;
    @(negedge clk);
    reset = 0;
    repeat(2) @(posedge clk);

   
    avalon_write(9'h000, 32'h0A);
    avalon_write(9'h000, 32'h0B);
    avalon_write(9'h000, 32'h0C);

    
    avalon_write(9'h100, 32'd3);   // payload_len = 3
    avalon_write(9'h101, 32'd0);   // inc_flag    = 0
    avalon_write(9'h102, 32'd0);   // cmp_flag    = 0
    avalon_write(9'h103, 32'd1);   // sys_id      = 1
    avalon_write(9'h104, 32'd1);   // comp_id     = 1
    avalon_write(9'h105, 32'd0);   // msg_id      = 0

    
    wait(uut.u_mav.MAVLink_busy == 1'b0);
    repeat(2) @(posedge clk);
    avalon_write(9'h106, 32'd1);

    #15000000;

    repeat(10) @(posedge clk);
    $display("[%0t] Xong", $time);
    $stop;
end


task avalon_write;
    input [8:0]  addr;
    input [31:0] data;
    begin
        @(negedge clk);      
        address   = addr;
        writedata = data;
        write     = 1;
        @(posedge clk);      
        #1;                  
        write     = 0;
        address   = 9'h0;
        writedata = 32'h0;
    end
endtask
endmodule