`timescale 1ns / 1ps

module modulo_tb #(parameter SIZE = 128);

   // Inputs
   reg clk;
   reg rst;
   reg [SIZE-1 : 0] dividen;
   reg 		    dividen_tvalid;
   reg [SIZE-1 : 0] divisor;
   reg 		    divisor_tvalid;
   reg 		    output_tready;

   // Outputs
   wire 	    dividen_tready;
   wire 	    divisor_tready;
   wire [SIZE-1 : 0] output_tdata;
   wire 	     output_tvalid;

   // Instantiate the Unit Under Test (UUT)
   modulo uut(
	      .clk(clk), 
	      .rst(rst), 
	      .input_dividen_tdata(dividen), 
	      .input_dividen_tvalid(dividen_tvalid), 
	      .input_dividen_tready(dividen_tready), 
	      .input_divisor_tdata(divisor), 
	      .input_divisor_tvalid(divisor_tvalid), 
	      .input_divisor_tready(divisor_tready), 
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
      dividen = 128'd143563;
      dividen_tvalid = 1;
      divisor = 128'd2137;
      divisor_tvalid = 1;
      output_tready = 0;
      #5;
      output_tready = 1;	

      
      // Wait 100 ns for global reset to finish
      #200;
      
      // Add stimulus here

   end
   
endmodule

