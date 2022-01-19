`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:39:56 01/13/2022
// Design Name:   karatsuba_mult
// Module Name:   /home/aaron/crypto/karatsba_128_tb.v
// Project Name:  crypto
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: karatsuba_mult
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module karatsba_128_tb #(parameter SIZE = 32);

	// Inputs
	reg clk;
	reg rst;
	reg [(SIZE/2)-1:0] input_a_tdata;
	reg [(SIZE/2)-1:0] input_b_tdata;
	reg input_a_tvalid;
	reg input_b_tvalid;
	reg output_tready;

	// Outputs
	wire input_a_tready;
	wire input_b_tready;
	wire [SIZE-1:0] output_tdata;
	wire output_tvalid;

	// Instantiate the Unit Under Test (UUT)
	karatsuba_mult uut (
		.clk(clk), 
		.rst(rst), 
		.input_a_tdata(input_a_tdata), 
		.input_b_tdata(input_b_tdata), 
		.input_a_tvalid(input_a_tvalid), 
		.input_b_tvalid(input_b_tvalid), 
		.input_a_tready(input_a_tready), 
		.input_b_tready(input_b_tready), 
		.output_tdata(output_tdata), 
		.output_tvalid(output_tvalid), 
		.output_tready(output_tready)
	);
	
	initial begin
		clk = 0;
		forever begin
			#10 clk = ~clk;
		end
	end
	
	initial begin
		// Initialize Inputs
		rst = 0;
		//input_a_tdata = 64'd123123124443;
		input_a_tdata = 16'd1332;
		input_a_tvalid = 1;
		//input_b_tdata = 64'd314141255378583275;
		input_b_tdata = 16'd544;
		input_b_tvalid = 1;
		#12
		output_tready = 1;

		// Wait 100 ns for global reset to finish
		#100;
		// Add stimulus here

	end
      
endmodule

