
module mavlink_rx #(
    parameter MAX_PAYLOAD = 255
)(
    input wire clk, reset,

    
    output reg  [7:0]  payload_len,
    output reg  [7:0]  finc_flag,
    output reg  [7:0]  fcmp_flag,
    output reg  [7:0]  fsys_id,
    output reg  [7:0]  fcomp_id,
    output reg  [23:0] fmsg_id,
    output reg  [7:0]  fseq,

    
    input wire rx_done_tick,
    input wire [7:0] uart_data,

   
    output reg fifo_wr_en,
    output reg [7:0] fifo_din,

    // CRC 
    output reg        crc_init,
    output reg        crc_valid,
    output reg  [7:0] crc_data,
    input  wire [15:0] crc_result,

    input wire isFull,
    
    //input  wire [7:0] crc_extra_byte,

    //output reg dataValid,
    output reg rx_busy,
    output wire [4:0] db_state,
	 
	 output reg	[31:0] bad_prefix_count,
	 output reg [31:0] bad_header_count,
	 output reg [31:0] bad_crc_count,
	 output reg [31:0] frame_ok_count,
	 output reg [31:0] frame_uart_count
    
);

    
    localparam [4:0]
        idle         = 5'd0,
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
        crc_extra_st = 5'd15,
        crc_wait     = 5'd16,  
        crc_0        = 5'd12,   
        crc_1        = 5'd13,
        fifo         = 5'd18,   
        done         = 5'd14;

    reg [4:0] state;
    reg mavlink_rx_done;
        
    
    reg [7:0] seq_cnt;
    reg [7:0] rx_crc_low; 
    reg [23:0] msg_id_tmp;
    reg [7:0] crc_extra_byte;

    //
    reg [15:0] cnt;
    reg [7:0] fifo_buf [0:MAX_PAYLOAD+12];
    integer i;
    
    always @* begin
        case(fmsg_id)
        24'd0: crc_extra_byte = 8'd50;
        24'd253: crc_extra_byte = 8'd83;
        default: crc_extra_byte = 8'd0;
        endcase
    end
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= idle;
            payload_len  <= 8'd0;
            finc_flag    <= 8'd0;
            fcmp_flag    <= 8'd0;
            fsys_id      <= 8'd0;
            fcomp_id     <= 8'd0;
            fmsg_id      <= 24'd0;
            fseq         <= 8'd0;
            fifo_wr_en   <= 1'b0;
            fifo_din     <= 8'd0;
            //dataValid    <= 1'b0;
            seq_cnt      <= 8'd0;
            rx_crc_low   <= 8'd0;
            msg_id_tmp   <= 24'd0;
            crc_init     <= 1'b0;
            crc_valid    <= 1'b0;
            crc_data     <= 8'd0;
            rx_busy <= 1'b0;
				mavlink_rx_done <= 1'b0;
				
				bad_prefix_count <= 31'd0;
				bad_header_count <= 31'd0;
				bad_crc_count <= 31'd0;
				frame_ok_count <= 31'd0;
				//frame_uart_count <= 31'd0;
				
            cnt <= 16'd0;
            for(i = 0;i <= 267; i = i + 1) begin
                fifo_buf[i] <= 0;
            end
        end else begin
           
            fifo_wr_en <= 1'b0;
            crc_valid  <= 1'b0;
            crc_init   <= 1'b0;
            //dataValid  <= 1'b0;

            case (state)

                idle: begin
							mavlink_rx_done <= 1'b0;
                    if (rx_done_tick) begin
								if(uart_data == 8'hFD) begin
								crc_init <= 1'b1;
                        seq_cnt  <= 8'd0;
                        fifo_buf[0] <= 8'hFD;
                        state    <= len;
                        rx_busy <= 1;
								end else begin
								bad_prefix_count <= bad_prefix_count +1;
								end
                        
                    end
                end

                len: begin
                    if (rx_done_tick) begin
								if(uart_data <= MAX_PAYLOAD) begin
								payload_len <= uart_data;
                        crc_data    <= uart_data;
                        crc_valid   <= 1'b1;
                        fifo_buf[1] <= uart_data;
                        state       <= inc_flag;
								end else begin
									bad_header_count <= bad_header_count + 1;
									state <= idle;
								end
                        
                    end
                end

                inc_flag: begin
                    if (rx_done_tick) begin
                        finc_flag <= uart_data;
                        crc_data  <= uart_data;
                        crc_valid <= 1'b1;
                        fifo_buf[2] <= uart_data;
                        state     <= cmp_flag;
                    end
                end

                cmp_flag: begin
                    if (rx_done_tick) begin
                        fcmp_flag <= uart_data;
                        crc_data  <= uart_data;
                        crc_valid <= 1'b1;
                        fifo_buf[3] <= uart_data;
                        state     <= seq;
                    end
                end

                seq: begin
                    if (rx_done_tick) begin
                        fseq      <= uart_data;
                        crc_data  <= uart_data;
                        crc_valid <= 1'b1;
                        fifo_buf[4] <= uart_data;
                        state     <= sys_id;
                    end
                end

                sys_id: begin
                    if (rx_done_tick) begin
                        fsys_id   <= uart_data;
                        crc_data  <= uart_data;
                        crc_valid <= 1'b1;
                        fifo_buf[5] <= uart_data;
                        state     <= comp_id;
                    end
                end

                comp_id: begin
                    if (rx_done_tick) begin
                        fcomp_id  <= uart_data;
                        crc_data  <= uart_data;
                        crc_valid <= 1'b1;
                        fifo_buf[6] <= uart_data;
                        state     <= msg_id_1;
                    end
                end

                msg_id_1: begin
                    if (rx_done_tick) begin
                        msg_id_tmp[7:0] <= uart_data;
                        crc_data        <= uart_data;
                        crc_valid       <= 1'b1;
                        fifo_buf[7] <= uart_data;
                        state           <= msg_id_2;
                    end
                end

                msg_id_2: begin
                    if (rx_done_tick) begin
                        msg_id_tmp[15:8] <= uart_data;
                        crc_data         <= uart_data;
                        crc_valid        <= 1'b1;
                        fifo_buf[8] <= uart_data;
                        state            <= msg_id_3;
                    end
                end

                msg_id_3: begin
                    if (rx_done_tick) begin
                        msg_id_tmp[23:16] <= uart_data;
                        fmsg_id           <= {uart_data, msg_id_tmp[15:0]};
                        crc_data          <= uart_data;
                        crc_valid         <= 1'b1;
                        seq_cnt           <= 8'd0;
                        fifo_buf[9] <= uart_data;
                        if (payload_len == 8'd0)
                            state <= crc_extra_st;
                        else
                            state <= payload;
                    end
                end

                payload: begin
                    if (seq_cnt == payload_len) begin
                        state <= crc_extra_st;
                    end else if (rx_done_tick) begin
                        //fifo_wr_en <= 1'b1;
                        //fifo_din   <= uart_data;
                        fifo_buf[10 + seq_cnt] <= uart_data;
                        crc_data   <= uart_data;
                        crc_valid  <= 1'b1;
                        seq_cnt    <= seq_cnt + 8'd1;
                        
                        if (seq_cnt + 8'd1 == payload_len)
                            state <= crc_extra_st;
                        else
                            state <= payload_wait;
                    end
                end

                payload_wait: begin
                    state <= payload;
                end

                
                crc_extra_st: begin
                    crc_data  <= crc_extra_byte;
                    crc_valid <= 1'b1;
                    
                    state     <= crc_wait;
                end
                crc_wait: begin
                    state <= crc_0;
                end

                crc_0: begin
                    if (rx_done_tick) begin
                        rx_crc_low <= uart_data;
                        fifo_buf[10 + payload_len] <= uart_data;
                        state      <= crc_1;
                    end
                end

                crc_1: begin
                    if (rx_done_tick) begin
                        if (rx_crc_low == crc_result[7:0] &&
                            uart_data  == crc_result[15:8]) begin
                            fifo_buf[11 + payload_len] <= crc_result[15:8];
                            
                            cnt       <= 16'd0;
									 frame_ok_count <= frame_ok_count + 1;
                            state <= fifo;
                            end
                        else begin
									 bad_crc_count <= bad_crc_count + 1;
                            state <= done;
                        end
                            
                        
                    end
                end
                fifo: begin
                    if(!isFull) begin
                        if(cnt == payload_len + 12) begin
                            state <= done;
                            cnt <= 0;
                            //dataValid <= 1'b1;
                        end else begin
                            fifo_wr_en <= 1'b1;
                            fifo_din   <= fifo_buf[cnt];
                            cnt <= cnt + 1;
                        end
                    end
                end
                done: begin
                    for(i = 0;i <= 267; i = i + 1) begin
                    fifo_buf[i] <= 0;
                    end
                    rx_busy <= 1'b0;
						  mavlink_rx_done <= 1;
                    state <= idle;
                    
                end

                default: state <= idle;
            endcase
        end
    end
    
	 always@(posedge clk, posedge reset) begin
			if(reset) begin
				frame_uart_count <= 31'd0;
			end else begin
				if(rx_done_tick) begin
					frame_uart_count <= frame_uart_count + 1;
				end
			end
	 end
    (* keep *) reg [63:0] mavlink_rx_dbg;
    always @* begin
        case (state)
            idle         : mavlink_rx_dbg = "idle    ";
            len          : mavlink_rx_dbg = "len     ";
            inc_flag     : mavlink_rx_dbg = "inc_flag";
            cmp_flag     : mavlink_rx_dbg = "cmp_flag";
            seq          : mavlink_rx_dbg = "seq     ";
            sys_id       : mavlink_rx_dbg = "sys_id  ";
            comp_id      : mavlink_rx_dbg = "comp_id ";
            msg_id_1     : mavlink_rx_dbg = "msg_id_1";
            msg_id_2     : mavlink_rx_dbg = "msg_id_2";
            msg_id_3     : mavlink_rx_dbg = "msg_id_3";
            payload      : mavlink_rx_dbg = "payload ";
            payload_wait : mavlink_rx_dbg = "pl_wait ";
            crc_extra_st : mavlink_rx_dbg = "crc_xtra";
            crc_wait     : mavlink_rx_dbg = "crc_wait";
            crc_0        : mavlink_rx_dbg = "crc_0   ";
            crc_1        : mavlink_rx_dbg = "crc_1   ";
            fifo        : mavlink_rx_dbg = "fifo";
            done         : mavlink_rx_dbg = "done    ";
            default      : mavlink_rx_dbg = "xxx";
        endcase
    end
    assign db_state = state;
endmodule