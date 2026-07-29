	component proj is
		port (
			clk_clk                            : in  std_logic                    := 'X'; -- clk
			leds_0_conduit_end_readdata        : out std_logic_vector(9 downto 0);        -- readdata
			reset_reset_n                      : in  std_logic                    := 'X'; -- reset_n
			rx_0_conduit_end_rx                : in  std_logic                    := 'X'; -- rx
			tx_0_conduit_end_tx                : out std_logic;                           -- tx
			urx_0_conduit_end_1_1_1_new_signal : in  std_logic                    := 'X'  -- new_signal
		);
	end component proj;

	u0 : component proj
		port map (
			clk_clk                            => CONNECTED_TO_clk_clk,                            --                     clk.clk
			leds_0_conduit_end_readdata        => CONNECTED_TO_leds_0_conduit_end_readdata,        --      leds_0_conduit_end.readdata
			reset_reset_n                      => CONNECTED_TO_reset_reset_n,                      --                   reset.reset_n
			rx_0_conduit_end_rx                => CONNECTED_TO_rx_0_conduit_end_rx,                --        rx_0_conduit_end.rx
			tx_0_conduit_end_tx                => CONNECTED_TO_tx_0_conduit_end_tx,                --        tx_0_conduit_end.tx
			urx_0_conduit_end_1_1_1_new_signal => CONNECTED_TO_urx_0_conduit_end_1_1_1_new_signal  -- urx_0_conduit_end_1_1_1.new_signal
		);

