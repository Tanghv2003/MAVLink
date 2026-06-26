module tb_fifo();
    reg clk;
    reg reset;
    reg [7:0] din;
    wire [7:0] dout;
    reg wr_en;
    reg rd_en;
    wire full;
    wire empty;
    wire valid;
    sync_fifo uut(
        .clk(clk),
        .reset(reset),
        .din(din),
        .dout(dout),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .isFull(full),
        .isEmpty(empty),
        .dataValid(valid)
    );
    initial begin
        clk <= 0;
        //reset <= 0;
        wr_en <= 0;
        rd_en <= 0;
        din <= 0;
    end
    always #5 clk = ~clk;

    initial begin
        reset <= 1;
        #5;
        reset <= 0;
        wr_en <=  1;
        din <= 8'b10;
        @(posedge clk);
        din <= 8'b11;
        @(posedge clk);
        din <= 8'b01;
        @(posedge clk);
        wr_en <= 0;
        @(posedge clk);
        rd_en <= 1;
        @(posedge clk);
        rd_en <= 1;
        @(posedge clk);
        rd_en <= 0;
        #100;
        $display("\nend simulation");
        $stop;

    end
endmodule