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

module main_tb;

   // Inputs
   reg clk;
   reg rst;
   
   //outputs
   reg start, finish;

   // Instantiate the Unit Under Test (UUT)
   main uut(
	    .clk(clk), 
	    .rst(rst), 
	    .start(start),
	    .finish(finish)
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
      start = 1;
      // Wait 100 ns for global reset to finish
      #100;
      
      // Add stimulus here

   end
   
endmodule

