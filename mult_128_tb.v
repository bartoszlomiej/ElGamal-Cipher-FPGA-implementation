`timescale 1ns / 1ps

module mult_128_tb;
   
   // Inputs
   reg clk;
   reg rst;
   reg [63:0] input_a_tdata;
   reg [63:0] input_b_tdata;
   reg 	      input_a_tvalid;
   reg 	      input_b_tvalid;
   reg 	      output_tready;

   // Outputs
   wire       input_a_tready;
   wire       input_b_tready;
   wire [127:0] output_tdata;
   wire 	output_tvalid;

   // Instantiate the Unit Under Test (UUT)
   mult_128 uut (
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
//      input_a_tdata = 64'd123123124443096802;
//      input_b_tdata = 64'd314141255378583275;
      input_a_tdata = 64'd9223372036854775337;
      input_b_tdata = 64'd9223372036854775337;
      #5;
      input_a_tvalid = 1;
      input_b_tvalid = 1;
      #12;
      output_tready = 1;

      // Wait 100 ns for global reset to finish
      #100;
      // Add stimulus here

   end
   
endmodule

/*
772F9A9308D2F4ECEC030C49E6D76 
------------------------6D76 
772F9A----------------------
 */
