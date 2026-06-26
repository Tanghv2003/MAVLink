`default_nettype none

module MAVLink_tx #(
    parameter MAX_PAYLOAD = 255
)(
    input  wire        clk, reset,
    input  wire        MAVLink_start,
    input  wire        uart_done_tick,

    
    input  wire [7:0]  payload_len,
    input  wire [7:0]  finc_flag,
    input  wire [7:0]  fcmp_flag,
    input  wire [7:0]  fsys_id,
    input  wire [7:0]  fcomp_id,
    input  wire [23:0] fmsg_id,

    
    input  wire [7:0]  din,
    input  wire        dinValid,
    output reg  [7:0]  rd_addr,
    output reg         rd_en,

    
    output reg         uart_tx_start,
    output reg  [7:0]  uart_data,
    output reg         MAVLink_busy,

   
    output reg  [7:0]  crc_out,
    output reg         crc_valid,   
    output reg         crc_init,    
    input  wire [15:0] crc_in

    //input  wire [7:0]  crc_extra_byte
);
    reg [7:0] crc_extra_byte;
    always@* begin
        case(fmsg_id)
        24'd0: crc_extra_byte = 8'd50;
        24'd253: crc_extra_byte = 8'd83;
        default: crc_extra_byte = 8'd0;
        endcase
    end
    
    localparam [4:0]
        idle         = 5'd0,
        stx          = 5'd1,
        len          = 5'd2,
        inc_flag     = 5'd3,
        cmp_flag     = 5'd4,
        seq          = 5'd5,
        sys_id       = 5'd6,
        comp_id      = 5'd7,
        msg_id_1     = 5'd8,
        msg_id_2     = 5'd9,
        msg_id_3     = 5'd10,
        payload      = 5'd11,
        payload_wait = 5'd17,
        payload_uart = 5'd18,
        crc_extra_st = 5'd15,   
        crc_wait     = 5'd16,
        crc_0        = 5'd12,
        crc_1        = 5'd13,
        done         = 5'd14;

    reg [4:0] state;
    reg [7:0] pay_cnt;
    reg [7:0] seq_cnt;

    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            seq_cnt <= 8'd0;
        end else if (state == done) begin
            seq_cnt <= seq_cnt + 8'd1;
        end
    end

    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state         <= idle;
            uart_tx_start <= 1'b0;
            uart_data     <= 8'd0;
            MAVLink_busy  <= 1'b0;
            crc_out       <= 8'd0;
            crc_valid     <= 1'b0;
            crc_init      <= 1'b0;
            pay_cnt       <= 8'd0;
            rd_addr       <= 8'd0;
            rd_en         <= 1'b0;
        end else begin
            
            crc_valid <= 1'b0;
            crc_init  <= 1'b0;

            case (state)
                idle: begin
                    MAVLink_busy <= 1'b0;
                    if (MAVLink_start) begin
                        MAVLink_busy  <= 1'b1;
                        crc_init      <= 1'b1;   
                        uart_data     <= 8'hFD;  
                        uart_tx_start <= 1'b1;
                        state         <= stx;
                    end
                end

                stx: begin
                    if (uart_done_tick) begin
                        uart_tx_start <= 1'b0;
                        uart_data     <= payload_len;
                        uart_tx_start <= 1'b1;
                        state         <= len;
                    end
                end

                len: begin
                    if (uart_done_tick) begin
                        uart_tx_start <= 1'b0;
                        crc_out       <= payload_len;
                        crc_valid     <= 1'b1; 
                        
                        uart_data     <= finc_flag;
                        uart_tx_start <= 1'b1;
                        state         <= inc_flag;
                    end
                end

                inc_flag: begin
                    if (uart_done_tick) begin
                        uart_tx_start <= 1'b0;
                        crc_out       <= finc_flag;
                        crc_valid     <= 1'b1;
                        
                        uart_data     <= fcmp_flag;
                        uart_tx_start <= 1'b1;
                        state         <= cmp_flag;
                    end
                end

                cmp_flag: begin
                    if (uart_done_tick) begin
                        uart_tx_start <= 1'b0;
                        crc_out       <= fcmp_flag;
                        crc_valid     <= 1'b1;
                        
                        uart_data     <= seq_cnt;
                        uart_tx_start <= 1'b1;
                        state         <= seq;
                    end
                end

                seq: begin
                    if (uart_done_tick) begin
                        uart_tx_start <= 1'b0;
                        crc_out       <= seq_cnt;
                        crc_valid     <= 1'b1;
                        
                        uart_data     <= fsys_id;
                        uart_tx_start <= 1'b1;
                        state         <= sys_id;
                    end
                end

                sys_id: begin
                    if (uart_done_tick) begin
                        uart_tx_start <= 1'b0;
                        crc_out       <= fsys_id;
                        crc_valid     <= 1'b1;
                        
                        uart_data     <= fcomp_id;
                        uart_tx_start <= 1'b1;
                        state         <= comp_id;
                    end
                end

                comp_id: begin
                    if (uart_done_tick) begin
                        uart_tx_start <= 1'b0;
                        crc_out       <= fcomp_id;
                        crc_valid     <= 1'b1;
                        
                        uart_data     <= fmsg_id[7:0];
                        uart_tx_start <= 1'b1;
                        state         <= msg_id_1;
                    end
                end

                msg_id_1: begin
                    if (uart_done_tick) begin
                        uart_tx_start <= 1'b0;
                        crc_out       <= fmsg_id[7:0];
                        crc_valid     <= 1'b1;
                        
                        uart_data     <= fmsg_id[15:8];
                        uart_tx_start <= 1'b1;
                        state         <= msg_id_2;
                    end
                end

                msg_id_2: begin
                    if (uart_done_tick) begin
                        uart_tx_start <= 1'b0;
                        crc_out       <= fmsg_id[15:8];
                        crc_valid     <= 1'b1;
                        
                        uart_data     <= fmsg_id[23:16];
                        uart_tx_start <= 1'b1;
                        state         <= msg_id_3;
                    end
                end

                msg_id_3: begin
                    if (uart_done_tick) begin
                        uart_tx_start <= 1'b0;
                        crc_out       <= fmsg_id[23:16];
                        crc_valid     <= 1'b1;
                        
                        pay_cnt       <= 8'd0;
                        if (payload_len == 8'd0) begin
                            state <= crc_extra_st;
                        end else begin
                            // rd_addr <= 8'd0;
                            // rd_en   <= 1'b1;
                            state   <= payload;
                        end
                    end
                end

                payload: begin
                    if(pay_cnt == payload_len) begin
                        state <= crc_extra_st;
                    end else begin
                        rd_en <= 1;
                        state <= payload_wait;
                    end
                end
                payload_wait: begin
                    rd_en <= 1'b0;            
                    if (dinValid) begin      
                        uart_data     <= din;
                        uart_tx_start <= 1'b1;
                        state <= payload_uart;
                    end
                end
                payload_uart: begin
                    if (uart_done_tick) begin
                        uart_tx_start <= 1'b0;
                        crc_out       <= uart_data;
                        crc_valid     <= 1'b1;
                        pay_cnt       <= pay_cnt + 8'd1;
                        state         <= payload;
                    end
                end
                crc_extra_st: begin
                    crc_out   <= crc_extra_byte;
                    crc_valid <= 1'b1;    
                    state     <= crc_wait; 
                end

                crc_wait: begin
                    state     <= crc_0;
                end

                crc_0: begin
                    uart_data     <= crc_in[7:0];
                    uart_tx_start <= 1'b1;
                    if (uart_done_tick) begin
                        uart_tx_start <= 1'b0;
                        state         <= crc_1;
                    end
                end

                crc_1: begin
                    uart_data     <= crc_in[15:8];
                    uart_tx_start <= 1'b1;
                    if (uart_done_tick) begin
                        uart_tx_start <= 1'b0;
                        state         <= done;
                    end
                end

                done: begin
                    MAVLink_busy <= 1'b0;
                    state        <= idle;
                end

                default: state <= idle;
            endcase
        end
    end

    
    reg [63:0] mavlink_tx_dbg;
    always @* begin
        case (state)
            idle        : mavlink_tx_dbg = "idle    ";
            stx         : mavlink_tx_dbg = "stx     ";
            len         : mavlink_tx_dbg = "len     ";
            inc_flag    : mavlink_tx_dbg = "inc_flag";
            cmp_flag    : mavlink_tx_dbg = "cmp_flag";
            seq         : mavlink_tx_dbg = "seq     ";
            sys_id      : mavlink_tx_dbg = "sys_id  ";
            comp_id     : mavlink_tx_dbg = "comp_id ";
            msg_id_1    : mavlink_tx_dbg = "msg_id_1";
            msg_id_2    : mavlink_tx_dbg = "msg_id_2";
            msg_id_3    : mavlink_tx_dbg = "msg_id_3";
            payload     : mavlink_tx_dbg = "payload ";
            payload_wait : mavlink_tx_dbg = "pl_wait";
            payload_uart : mavlink_tx_dbg = "pl_uart";
            crc_extra_st: mavlink_tx_dbg = "crc_xtra";
            crc_wait    : mavlink_tx_dbg = "crc_wait";
            crc_0       : mavlink_tx_dbg = "crc_0   ";
            crc_1       : mavlink_tx_dbg = "crc_1   ";
            done        : mavlink_tx_dbg = "done    ";
            default     : mavlink_tx_dbg = " ";
        endcase
    end

endmodule



