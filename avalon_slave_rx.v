module avalon_slave_rx (
    input wire clk, reset,

    // slave
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
    uart_rx rx_uut(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tick(tick),
        .rx_done_tick(rx_done_tick),
        .dout(dout),
        .db_uart_rx_state(db_uart_rx_state)
    );

    //
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
        .din(fifo_in),
        .dout(fifo_out),
        .isFull(isFull),
        .isEmpty(isEmpty),
        .dataValid(fifo_dataValid)
    );

    //
    wire crc_init, crc_valid;
    wire [7:0] crc_in;
    wire [15:0] crc_out;

    crc16 crc_uuut(
        .clk(clk),
        .reset(reset),
        .init(crc_init),
        .valid(crc_valid),
        .data_in(crc_in),
        .crc_out(crc_out)
    );

    //

    wire  [7:0]  payload_len;
    wire  [7:0]  finc_flag;
    wire  [7:0]  fcmp_flag;
    wire  [7:0]  fsys_id;
    wire  [7:0]  fcomp_id;
    wire  [23:0] fmsg_id;
    wire  [7:0]  fseq;
    //wire ml_dataValid;
    reg dataValid_reg;
    wire busy;
    wire [4:0] db_state;
    mavlink_rx ml_rx(
        .clk(clk),
        .reset(reset),
        
        .payload_len(payload_len),
        .finc_flag(finc_flag),
        .fcmp_flag(fcmp_flag),
        .fsys_id(fsys_id),
        .fcomp_id(fcomp_id),
        .fmsg_id(fmsg_id),
        .fseq(fseq),

        .rx_done_tick(rx_done_tick),
        .uart_data(dout),

        .fifo_wr_en(wr_en),
        .fifo_din(fifo_in),

        .crc_init(crc_init),
        .crc_valid(crc_valid),
        .crc_data(crc_in),
        .crc_result(crc_out),
        .isFull(isFull),
        //.dataValid(ml_dataValid),
        .rx_busy(busy),
        .db_state(db_state)
    );

    
    wire  clear_dataValid = (write && (address == 9'h109));

    // always @(posedge clk or posedge reset) begin
    //     if (reset)
    //         dataValid_reg <= 1'b0;
    //     else begin
    //         if (ml_dataValid)
    //             dataValid_reg <= 1'b1;
    //         else if (clear_dataValid)
    //             dataValid_reg <= 1'b0;
    //     end
    // end

    
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
                9'h101: readdata <= {24'd0, payload_len};
                9'h102: readdata <= {24'd0, finc_flag};
                9'h103: readdata <= {24'd0, fcmp_flag};
                9'h104: readdata <= {24'd0, fsys_id};
                9'h105: readdata <= {24'd0, fcomp_id};
                9'h106: readdata <= {8'd0,  fmsg_id};
                9'h107: readdata <= {24'd0, fseq};
                9'h108: readdata <= {31'd0, busy};
                9'h10A: readdata <= {31'd0, isEmpty};
                9'h10B: readdata <= {31'd0, isFull};
                9'h10C: readdata <= {27'd0, db_state};
                9'h10D: readdata <= {30'd0, db_uart_rx_state};
                default: readdata <= 32'hAAAABBBB;
            endcase
        end

    end
end
endmodule