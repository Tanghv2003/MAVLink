`timescale 1 ps / 1 ps
module leds (
        input  wire        clk,
        input  wire        reset,
        input  wire [1:0]  avs_address,
        input  wire        avs_write,
        input  wire        avs_read,
        input  wire [31:0] avs_writedata,
        output reg  [31:0] avs_readdata,
        output wire        avs_waitrequest,

        output reg  [9:0]  led_out
    );

    assign avs_waitrequest = 1'b0;

    localparam ADDR_LED = 2'h0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            led_out      <= 10'd0;
            avs_readdata <= 32'd0;
        end else begin
            if (avs_write && avs_address == ADDR_LED) begin
                led_out <= avs_writedata[9:0];
            end
            if (avs_read && avs_address == ADDR_LED) begin
                avs_readdata <= {22'd0, led_out};
            end else begin
                avs_readdata <= 32'd0;
            end

        end
    end

endmodule