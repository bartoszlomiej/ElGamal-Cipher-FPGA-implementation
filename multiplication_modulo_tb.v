`timescale 1ns / 1ps

module multiplication_modulo_tb #(parameter SIZE = 64);

   // Inputs
   reg clk;
   reg rst;
   reg [SIZE-1 : 0] multiplier; //just for dbg - size
   reg 			multiplier_tvalid;
   reg [SIZE-1 : 0] multiplicand;
   reg 			multiplicand_tvalid;
   reg [SIZE-1 : 0] modulus;
   reg 			modulus_tvalid;
   reg 			output_tready;

   // Outputs
   wire 		multiplier_tready;
   wire 		multiplicand_tready;
   wire [SIZE-1 : 0] 	output_tdata;
   wire 		output_tvalid;
   

   // Instantiate the Unit Under Test (UUT)
   multiplication_modulo uut(
	      .clk(clk), 
	      .rst(rst), 
	      .input_multiplier_tdata(multiplier), 
	      .input_multiplier_tvalid(multiplier_tvalid), 
	      .input_multiplier_tready(multiplier_tready), 
	      .input_multiplicand_tdata(multiplicand), 
	      .input_multiplicand_tvalid(multiplicand_tvalid), 
	      .input_multiplicand_tready(multiplicand_tready),
	      .input_modulus_tdata(modulus), 
	      .input_modulus_tvalid(modulus_tvalid), 
	      .input_modulus_tready(modulus_tready), 
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
//      multiplier = 64'd143563561627;
      multiplier = 64'd9223372036854775337;
//      multiplier = 64'd1;
      multiplier_tvalid = 1;
//      multiplicand = 64'd21376213;
//      multiplicand = 64'd143563561627;
      multiplicand = 64'd9223372036854775337;
      multiplicand_tvalid = 1;
//      modulus = 64'd69814;
      modulus = 64'd9223372036854775433;
      modulus_tvalid = 1;
      
      output_tready = 0;
      #5;
      output_tready = 1;	

      
      // Wait 100 ns for global reset to finish
      #200;
      
      // Add stimulus here

   end
   
endmodule

