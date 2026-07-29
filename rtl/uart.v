    `default_nettype none
    module uart_tx #(
        parameter NUMBER_TICK = 16,
        parameter DATA_BIT    = 8
    )(
        input  wire       clk,
        input  wire       reset,
        input  wire       tx_start,
        input  wire       tick,
        input  wire [7:0] din,
        output reg        tx_done_tick,
        output wire       tx
    );

        
        localparam [1:0] IDLE  = 2'b00;
        localparam [1:0] START = 2'b01;
        localparam [1:0] DATA  = 2'b10;
        localparam [1:0] DONE  = 2'b11;

        
        reg [1:0] state_reg, state_next;
        reg [3:0] s_reg,     s_next;     
        reg [2:0] n_reg,     n_next;
        reg [7:0] data_reg,  data_next;
        reg       tx_reg,    tx_next;

        
        always @(posedge clk or posedge reset) begin
            if (reset) begin
                state_reg <= IDLE;
                s_reg     <= 4'd0;
                n_reg     <= 3'd0;
                data_reg  <= 8'd0;
                tx_reg    <= 1'b1;
            end else begin
                state_reg <= state_next;
                s_reg     <= s_next;
                n_reg     <= n_next;
                data_reg  <= data_next;
                tx_reg    <= tx_next;
            end
        end

        
        always @* begin
            
            state_next    = state_reg;
            s_next        = s_reg;
            n_next        = n_reg;
            data_next     = data_reg;
            tx_next       = tx_reg;
            tx_done_tick  = 1'b0;

            case (state_reg)

                IDLE: begin
                    tx_next = 1'b1;                
                    if (tx_start) begin
                        state_next = START;
                        s_next     = 4'd0;
                        data_next  = din;            
                    end
                end

                START: begin
                    tx_next = 1'b0;                
                    if (tick) begin
                        if (s_reg == NUMBER_TICK - 1) begin
                            s_next     = 4'd0;
                            n_next     = 3'd0;
                            state_next = DATA;
                        end else begin
                            s_next = s_reg + 4'd1;
                        end
                    end
                end

                DATA: begin
                    tx_next = data_reg[0];
                    if (tick) begin
                        if (s_reg == NUMBER_TICK - 1) begin
                            s_next    = 4'd0;
                            data_next = data_reg >> 1;
                            if (n_reg == DATA_BIT - 1) begin
                                state_next = DONE;// đã gửi đủ 8 bit
                            end else begin
                                n_next = n_reg + 3'd1;
                            end
                        end else begin
                            s_next = s_reg + 4'd1;
                        end
                    end
                end

                DONE: begin
                    tx_next = 1'b1;                
                    if (tick) begin
                        if (s_reg == NUMBER_TICK - 1) begin
                            state_next   = IDLE;
                            tx_done_tick = 1'b1;
                        end else begin
                            s_next = s_reg + 4'd1;
                        end
                    end
                end

                default: state_next = IDLE;

            endcase
        end

        
        reg [39:0] uart_tx_dbg_state;
        always @* begin
            case (state_reg)
                IDLE:    uart_tx_dbg_state = "idle ";
                START:   uart_tx_dbg_state = "start";
                DATA:    uart_tx_dbg_state = "data ";
                DONE:    uart_tx_dbg_state = "done ";
                default: uart_tx_dbg_state = "";
            endcase
        end
        

        assign tx = tx_reg;

    endmodule



   module uart_rx#(
    parameter NUMBER_TICK = 16,
    parameter DATA_BIT    = 8
)(
    input wire clk, reset,
    input wire rx,
    input wire tick,
     (* keep *) output reg rx_done_tick ,
    output wire [7:0] dout,
    output wire [1:0] db_uart_rx_state
);
    localparam [1:0] idle  = 2'b00;
    localparam [1:0] start = 2'b01;
    localparam [1:0] data  = 2'b10;
    localparam [1:0] done  = 2'b11;

    
    (* keep *) reg [1:0] state_reg ;
    (* keep *) reg [1:0] state_next ;
    
   
		reg [3:0] s_reg;
		reg [2:0] n_reg;
		reg [7:0] data_reg;
		reg [15:0] done_cnt;

   
		reg [3:0] s_next;
		reg [2:0] n_next;
		reg [7:0] data_next;
   
		
		reg rx_ff1, rx_ff2;
		always@(posedge clk, posedge reset) begin
			if(reset) begin
			rx_ff1 <= 1'b1;
			rx_ff2 <= 1'b1;
			end else begin
				rx_ff1 <= rx;
				rx_ff2 <= rx_ff1;
			end
		end
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state_reg <= idle;
            s_reg     <= 4'd0;
            n_reg     <= 3'd0;
            data_reg  <= 8'd0;
        end else begin
            state_reg <= state_next;
            s_reg     <= s_next;
            n_reg     <= n_next;
            data_reg  <= data_next;
        end
    end

    always @* begin
        state_next        = state_reg;
        rx_done_tick      = 1'b0;
        s_next            = s_reg;
        n_next            = n_reg;
        data_next         = data_reg;
        
        
        case (state_reg)
            idle: begin
                if (rx_ff2 == 0) begin
                    state_next = start;
                    s_next     = 0;
                    n_next     = 0;
                    data_next  = 0;
                end
            end
            start: begin
                if (tick) begin
                    if (s_reg == 7) begin
                        state_next = data;
                        s_next     = 0;
                        data_next  = 0;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
            data: begin
                if (tick) begin
                    if (s_reg == NUMBER_TICK - 1) begin
                        s_next    = 0;
                        data_next = {rx_ff2, data_reg[7:1]};
                        if (n_reg == DATA_BIT - 1) begin
                            state_next = done;
                        end else begin
                            n_next = n_reg + 1;
                        end
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
            done: begin
                if (tick) begin
                    if (s_reg == NUMBER_TICK - 1) begin
                        state_next      = idle;
                        rx_done_tick     = 1'b1;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
        endcase
    end

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            done_cnt <= 0;
        end else begin
            if (rx_done_tick) begin
                done_cnt <= done_cnt + 1;
            end
        end
    end

    assign dout              = data_reg;
    assign db_uart_rx_state  = state_reg;

endmodule