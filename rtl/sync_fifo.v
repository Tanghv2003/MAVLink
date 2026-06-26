module sync_fifo #(
    parameter DEPTH = 256,
    parameter DATA_WIDTH = 8
)(
    input wire clk, reset,
    input wire wr_en,rd_en,
    input wire [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout,
    output wire isFull,
    output wire isEmpty,
    output reg dataValid
);

reg [$clog2(DEPTH)-1:0] r_ptr;// con tro doc
reg [$clog2(DEPTH)-1:0] w_ptr;// con tro ghi

reg [DATA_WIDTH-1:0] fifo[0:DEPTH-1];

always@(posedge clk, posedge reset) begin
    if(reset) begin
        w_ptr <= 0;
    end else begin
        if(!isFull && wr_en) begin
            fifo[w_ptr] <= din;
            w_ptr <= w_ptr + 1;
        end
    end
end


//data ra sau 1 ck
always@(posedge clk, posedge reset) begin
    if(reset) begin
        r_ptr <= 0;
        dout <= 0;
    end else begin
        dataValid <= 0;
        if(!isEmpty && rd_en) begin
            dout <= fifo[r_ptr];
            r_ptr <= r_ptr + 1;
            dataValid <= 1;
        end
    end
end

assign isEmpty = (w_ptr == r_ptr);// khong co data de doc
assign isFull = (w_ptr + 1 == r_ptr);
// assign isEmpty = (w_ptr == r_ptr);
// assign isFull  = ((w_ptr + 1'b1) == r_ptr);
endmodule