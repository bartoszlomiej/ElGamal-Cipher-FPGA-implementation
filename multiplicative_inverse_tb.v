`timescale 1ns / 1ps

module mult_inverse_tb #(parameter SIZE = 64);

   // Inputs
   reg clk;
   reg rst;
   reg [SIZE-1 : 0] base; //just for dbg - size
   reg 		    base_tvalid;
   reg [SIZE-1 : 0] modulus;
   reg 		    modulus_tvalid;
   reg 		    output_tready;

   // Outputs
   wire 	    base_tready;
   wire [SIZE-1 : 0] output_tdata;
   wire 	     output_tvalid;
   

   // Instantiate the Unit Under Test (UUT)
   mult_inverse uut(
	       .clk(clk), 
	       .rst(rst), 
	       .input_base_tdata(base), 
	       .input_base_tvalid(base_tvalid), 
	       .input_base_tready(base_tready), 
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
      base = 64'd1435631627;
      base_tvalid = 1;
      modulus = 64'd69814;
      modulus_tvalid = 1;
      
      output_tready = 0;
      #5;
      output_tready = 1;	

      
      // Wait 100 ns for global reset to finish
      #200;
      
      // Add stimulus here

   end
   
endmodule

