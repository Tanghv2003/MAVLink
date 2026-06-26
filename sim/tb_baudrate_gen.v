module tb_baurate_gen();
reg clk;
reg reset;
wire tick;

baudrate_gen bd_uut(
    .clk(clk),
    .reset(reset),
    .tick(tick)
);

initial begin
    clk = 0;
    reset = 1;
end

always #5 clk = ~clk;
initial begin
    #20;
    reset = 0;

end
endmodule