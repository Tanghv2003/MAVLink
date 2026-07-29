// new_component.v

// This file was auto-generated as a prototype implementation of a module
// created in component editor.  It ties off all outputs to ground and
// ignores all inputs.  It needs to be edited to make it do something
// useful.
// 
// This file will not be automatically regenerated.  You should check it in
// to your version control system if you want to keep it.

`timescale 1 ps / 1 ps
module new_component (
		input  wire [8:0]  address,       //  avalon_slave.address
		input  wire        read,          //              .read
		output wire [31:0] readdata,      //              .readdata
		input  wire        write,         //              .write
		input  wire [31:0] writedata,     //              .writedata
		output wire        readdatavalid, //              .readdatavalid
		input  wire        clk,           //    clock_sink.clk
		input  wire        reset,         //    reset_sink.reset
		input  wire        rx             // conduit_end_1.new_signal
	);

	// TODO: Auto-generated HDL template

	assign readdata = 32'b00000000000000000000000000000000;

	assign readdatavalid = 1'b0;

endmodule
