`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:12:17 01/11/2022
// Design Name:   mult_32_pipeline_2
// Module Name:   /home/aaron/crypto/mult_32_pipeline_2_tb.v
// Project Name:  crypto
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mult_32_pipeline_2
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mult_32_pipeline_2_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [15:0] input_a_tdata;
	reg input_a_tvalid;
	reg [15:0] input_b_tdata;
	reg input_b_tvalid;
	reg output_tready;

	// Outputs
	wire input_a_tready;
	wire input_b_tready;
	wire [31:0] output_tdata;
	wire output_tvalid;

	// Instantiate the Unit Under Test (UUT)
	mult_32_pipeline_2 uut(
		.clk(clk), 
		.rst(rst), 
		.input_a_tdata(input_a_tdata), 
		.input_a_tvalid(input_a_tvalid), 
		.input_a_tready(input_a_tready), 
		.input_b_tdata(input_b_tdata), 
		.input_b_tvalid(input_b_tvalid), 
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
		input_a_tdata = 16'd690;
		input_a_tvalid = 1;
		input_b_tdata = 16'd2137;
		input_b_tvalid = 1;
		output_tready = 0;
		#5;
		output_tready = 1;	

		
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

