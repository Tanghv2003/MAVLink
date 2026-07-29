module uart_rx2#(
    parameter NUMBER_TICK = 16,
    parameter DATA_BIT    = 8
)(
    input  wire clk, reset,
    input  wire rx,
    input  wire tick,
    output reg  rx_done_tick,
    output wire [7:0] dout,
    output wire [1:0] db_uart_rx_state,
    output reg  uart_rx_busy,
    output wire [15:0] db_done_cnt
);
    localparam [1:0] idle  = 2'b00;
    localparam [1:0] start = 2'b01;
    localparam [1:0] data  = 2'b10;
    localparam [1:0] done  = 2'b11;
    
    (* keep = "true", noprune *) reg [1:0] state_reg, state_next;
    (* keep = "true", noprune *) reg [3:0] s_reg,     s_next;
    (* keep = "true", noprune *) reg [2:0] n_reg,     n_next;
    reg [7:0] data_reg,  data_next;
    (* keep = "true", noprune *) reg db_rx_done_tick;
    (* keep = "true", noprune *) reg [15:0] done_cnt;

	 
    reg rx_sync_1, rx_sync_2;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rx_sync_1 <= 1'b1;
            rx_sync_2 <= 1'b1;
        end else begin
            rx_sync_1 <= rx;
            rx_sync_2 <= rx_sync_1;
        end
    end

    
    always @(posedge clk or posedge reset) begin
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
        state_next      = state_reg;
        rx_done_tick    = 1'b0;
        s_next          = s_reg;
        n_next          = n_reg;
        data_next       = data_reg;
        db_rx_done_tick = 1'b0;
        uart_rx_busy    = (state_reg != idle);
        
        case (state_reg)
           
            idle: begin
                if (tick) begin
                    if (rx_sync_2 == 1'b0) begin
                        state_next = start;
                        s_next     = 0;
                        n_next     = 0;
                        data_next  = 0;
                    end
                end
            end
            
            start: begin
                if (tick) begin
                    if (s_reg == 7) begin
                        state_next = data;
                        s_next     = 0;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
            
            data: begin
                if (tick) begin
                    if (s_reg == NUMBER_TICK - 1) begin
                        s_next    = 0;
                        data_next = {rx_sync_2, data_reg[7:1]};
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
                        rx_done_tick    = 1'b1;
                        db_rx_done_tick = 1'b1;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
            default: state_next = idle;
        endcase
    end

    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            done_cnt <= 0;
        end else begin
            if (db_rx_done_tick) begin
                done_cnt <= done_cnt + 1;
            end
        end
    end

    assign dout             = data_reg;
    assign db_uart_rx_state = state_reg;
    assign db_done_cnt      = done_cnt;

endmodule