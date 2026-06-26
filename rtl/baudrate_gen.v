module baudrate_gen #(
    parameter BAUD_RATE = 9600,
    parameter f = 50000000
)(
    input wire clk, reset,
    output wire tick
);
    localparam div  = f/ (BAUD_RATE*16);
    reg [15:0] cnt;
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            cnt <= 0;
        end else begin
            if(cnt == div -1) begin
                cnt <= 0;
            end else begin
                cnt <= cnt + 1;
            end
        end
    end

    assign tick = (cnt == div - 1);
endmodule