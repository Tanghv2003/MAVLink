
module proj (
	clk_clk,
	leds_0_conduit_end_readdata,
	reset_reset_n,
	rx_0_conduit_end_rx,
	tx_0_conduit_end_tx);	

	input		clk_clk;
	output	[9:0]	leds_0_conduit_end_readdata;
	input		reset_reset_n;
	input		rx_0_conduit_end_rx;
	output		tx_0_conduit_end_tx;
endmodule
