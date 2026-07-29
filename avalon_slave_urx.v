module avalon_slave_urx(
    input wire clk, reset,

    input wire [8:0]  address,
    input wire        read,
    input wire        write,
    input wire [31:0] writedata,

    output reg [31:0] readdata,
    output reg        readdataValid,

    //
    input wire rx
);

    localparam ADDR_BASE = 9'h0;
    wire fifo_sel = (address <= ADDR_BASE + 9'h0ff);
    wire cf_sel = (address >= ADDR_BASE + 9'h100);



    wire tick;
    baudrate_gen #(
        .BAUD_RATE(9600),
        .f(50000000)
    ) bd_1(
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    wire rx_done_tick;
    wire [7:0] dout;
    wire db_uart_rx_state;
    wire busy;
    uart_rx2 rx_uut(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tick(tick),
        .rx_done_tick(rx_done_tick),
        .dout(dout),
        .db_uart_rx_state(db_uart_rx_state),
        .uart_rx_busy(busy)
    );

    wire wr_en,rd_en;
    wire [7:0] fifo_in, fifo_out;
    wire isFull, isEmpty;
    wire fifo_dataValid;
    reg flag_rdone;
    sync_fifo #(
        .DEPTH(2048),
        .DATA_WIDTH(8)
    )fifo_uut(  
        .clk(clk),
        .reset(reset),
        .wr_en(wr_en),
        .rd_en(read && fifo_sel && flag_rdone),
        .din(dout),
        .dout(fifo_out),
        .isFull(isFull),
        .isEmpty(isEmpty),
        .dataValid(fifo_dataValid)
    );


    always @(posedge clk or posedge reset) begin
    if (reset) begin
        readdata      <= 32'd0;
        readdataValid <= 1'b0;
        flag_rdone    <= 1'b1;
    end else begin
        readdataValid <= 1'b0;  

        if (read && fifo_sel && flag_rdone) begin
            flag_rdone <= 1'b0;
        end

        if (fifo_dataValid) begin
            readdata      <= {24'd0, fifo_out};// du lieu ra sau 1 clk
            readdataValid <= 1'b1;
            flag_rdone    <= 1'b1;
        end

       
        if (read && cf_sel) begin
            readdataValid <= 1'b1;  
            case (address)
                9'h10A: readdata <= {31'd0, isEmpty};
                9'h10B: readdata <= {31'd0, isFull};
                9'h10C: readdata <= {31'd0, busy};
                default: readdata <= 32'hAAAABBBB;
            endcase
        end

    end
end


endmodule