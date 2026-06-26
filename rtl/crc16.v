`default_nettype none

module crc16 (
    input  wire        clk,
    input  wire        reset,
    input  wire        init,        
    input  wire        valid,     
    input  wire [7:0]  data_in,
    output reg  [15:0] crc_out
);
    
    wire [7:0]  tmp  = data_in ^ crc_out[7:0];
    wire [7:0]  tmp2 = tmp ^ (tmp << 4);

    wire [15:0] crc_next =
        (crc_out >> 8)   ^
        ({tmp2, 8'h00})  ^   // tmp2 << 8
        ({5'h00, tmp2, 3'h0}) ^   // tmp2 << 3
        ({12'h000, tmp2[7:4]});    // tmp2 >> 4

    always @(posedge clk or posedge reset) begin
        if (reset)
            crc_out <= 16'hFFFF;
        else if (init)
            crc_out <= 16'hFFFF;
        else if (valid)
            crc_out <= crc_next;
    end

endmodule