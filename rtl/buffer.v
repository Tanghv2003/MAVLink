module buffer#(
    parameter W = 8
)(
    input clk, reset,
    input wire clr_flag, set_flag,
    input wire [W-1:0] din,
    output wire flag,
    output wire [W-1:0] dout
);
    reg [W-1:0] buf_reg, buf_next;
    reg flag_reg, flag_next;

    always@(posedge clk, posedge reset) begin
        if(reset) begin
            buf_reg <= 0;
            flag_reg <= 0;
        end else begin
            buf_reg <= buf_next;
            flag_reg <= flag_next;
        end
    end

    always@* begin
        buf_next = buf_reg;
        flag_next = flag_reg;
        if(set_flag) begin
            buf_next = din;
            flag_next = 1'b1;
        end else if(clr_flag) begin
            flag_next = 0;
        end
    end

    assign dout = buf_reg;
    assign flag = flag_reg;
endmodule