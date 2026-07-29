module top(
    input wire CLOCK_50, RESET_N,
    output wire [9:0] LEDR,
    output wire tx,
    input wire rx
);  
    // 	proj u0 (
	// 	.clk_clk                     (CLOCK_50),                     //                clk.clk
	// 	.leds_0_conduit_end_readdata (LEDR), // leds_0_conduit_end.readdata
	// 	.reset_reset_n               (RESET_N),               //              reset.reset_n
	// 	.tx_0_conduit_end_tx         (tx),         //   tx_0_conduit_end.tx
	// 	.rx_0_conduit_end_rx         (rx)          //   rx_0_conduit_end.rx
	// );
	// //assign tx = rx;

		proj u0 (
		.clk_clk                            (CLOCK_50),                            //                     clk.clk
		.leds_0_conduit_end_readdata        (LEDR),        //      leds_0_conduit_end.readdata
		.reset_reset_n                      (RESET_N),                      //                   reset.reset_n
		.rx_0_conduit_end_rx                (rx),                //        rx_0_conduit_end.rx
		.tx_0_conduit_end_tx                (tx),                //        tx_0_conduit_end.tx
		.urx_0_conduit_end_1_1_1_new_signal ()  // urx_0_conduit_end_1_1_1.new_signal
	);


	
endmodule