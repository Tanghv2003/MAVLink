module avalon_slave_tx(
    input wire clk,
    input wire reset,

    // Avalon Slave
    input wire [8:0]  address,
    input wire        read,
    input wire        write,
    input wire [31:0] writedata,

    output reg [31:0] readdata,
    output reg        readdataValid,

    output wire tx
);

    
    wire fifo_sel = (address <= 9'h0FF);
    wire cf_sel   = (address >= 9'h100);

    reg [7:0]  payload_len;
    reg [7:0]  finc_flag;
    reg [7:0]  fcmp_flag;
    reg [7:0]  fsys_id;
    reg [7:0]  fcomp_id;
    reg [23:0] fmsg_id;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            payload_len <= 8'd0;
            finc_flag   <= 8'd0;
            fcmp_flag   <= 8'd0;
            fsys_id     <= 8'd0;
            fcomp_id    <= 8'd0;
            fmsg_id     <= 24'd0;
        end
        else if(write && cf_sel) begin
            case(address)
                9'h100: payload_len <= writedata[7:0];
                9'h101: finc_flag   <= writedata[7:0];
                9'h102: fcmp_flag   <= writedata[7:0];
                9'h103: fsys_id     <= writedata[7:0];
                9'h104: fcomp_id    <= writedata[7:0];
                9'h105: fmsg_id     <= writedata[23:0];
                default:;
            endcase
        end
    end

    reg MAVLink_start_reg;

    wire MAVLink_start;
    assign MAVLink_start = MAVLink_start_reg;

    wire MAVLink_busy;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            MAVLink_start_reg <= 1'b0;
        end
        else begin
            MAVLink_start_reg <= 1'b0;

            if(write && cf_sel && !MAVLink_busy && (address == 9'h106))
            begin
                MAVLink_start_reg <= writedata[0];
            end
        end
    end

    wire isFull;
    wire isEmpty;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            readdata      <= 32'd0;
            readdataValid <= 1'b0;
        end
        else begin
            readdata      <= 32'd0;
            readdataValid <= 1'b0;

            if(read && cf_sel) begin
                case(address)

                    9'h107: begin
                        readdata      <= {31'd0,isFull};
                        readdataValid <= 1'b1;
                    end

                    9'h108: begin
                        readdata      <= {31'd0,isEmpty};
                        readdataValid <= 1'b1;
                    end
                    9'h109: begin
                        readdata      <= {31'd0,MAVLink_busy};
                        readdataValid <= 1'b1;
                    end
                    default: begin
                        readdata      <= 32'h0000AACC;
                        readdataValid <= 1'b1;
                    end

                endcase
            end
        end
    end

    
    wire       fifo_read;
    wire [7:0] fifo_out;
    wire       fifo_dataValid;

    sync_fifo #(
        .DEPTH(256),
        .DATA_WIDTH(8)
    ) fifo_1 (
        .clk(clk),
        .reset(reset),

        .wr_en(write && fifo_sel),
        .rd_en(fifo_read),

        .din(writedata[7:0]),
        .dout(fifo_out),

        .isFull(isFull),
        .isEmpty(isEmpty),
        .dataValid(fifo_dataValid)
    );

    
    wire tick;

    baudrate_gen #(
        .BAUD_RATE(9600),
        .f(50_000_000)
    ) u_baud (
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    
    wire uart_tx_start;
    wire uart_done_tick;
    wire [7:0] uart_tx_din;

    uart_tx #(
        .NUMBER_TICK(16),
        .DATA_BIT(8)
    ) u_uart (
        .clk(clk),
        .reset(reset),

        .tx_start(uart_tx_start),
        .tick(tick),
        .din(uart_tx_din),

        .tx_done_tick(uart_done_tick),
        .tx(tx)
    );

    
    wire        crc_init;
    wire        crc_valid;
    wire [7:0]  crc_din;
    wire [15:0] crc_out;

    crc16 u_crc (
        .clk(clk),
        .reset(reset),

        .init(crc_init),
        .valid(crc_valid),

        .data_in(crc_din),
        .crc_out(crc_out)
    );

    MAVLink_tx #(
        .MAX_PAYLOAD(255)
    ) u_mav (
        .clk(clk),
        .reset(reset),

        .MAVLink_start(MAVLink_start),
        .uart_done_tick(uart_done_tick),

        .payload_len(payload_len),
        .finc_flag(finc_flag),
        .fcmp_flag(fcmp_flag),
        .fsys_id(fsys_id),
        .fcomp_id(fcomp_id),
        .fmsg_id(fmsg_id),

        .din(fifo_out),
        .dinValid(fifo_dataValid),
        .rd_en(fifo_read),
        .rd_addr(),

        .uart_tx_start(uart_tx_start),
        .uart_data(uart_tx_din),

        .MAVLink_busy(MAVLink_busy),

        .crc_out(crc_din),
        .crc_valid(crc_valid),
        .crc_init(crc_init),
        .crc_in(crc_out),
    );

endmodule