module tb_mavlink_tx();

reg clk;
reg reset;

initial begin
    clk = 0;
    reset = 1;
end

always #5 clk = ~clk;

endmodule