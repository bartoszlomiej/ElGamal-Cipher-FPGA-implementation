`timescale 1ns / 1ps

module decrypting_entity_tb #(parameter SIZE = 64);

   // Inputs
   reg clk;
   reg rst;
   reg [SIZE-1 : 0] p; //just for dbg - size
   reg 		    p_tvalid;
   reg [SIZE-1 : 0] alpha;
   reg 		    alpha_tvalid;

   // Outputs
   wire [SIZE-1 : 0] p_out_tdata;
   wire 	     p_out_tvalid;
   reg 		     p_out_tready;
   
   wire [SIZE-1 : 0] alpha_out_tdata;
   wire 	     alpha_out_tvalid;   
   reg 		     alpha_out_tready;
   
   wire [SIZE-1 : 0] public_key;
   wire 	     public_key_tvalid;
   reg 		     public_key_tready;
   
   wire 	     output_tready;

   assign output_tready = p_out_tready & alpha_out_tready & public_key_tready;

   // Instantiate the Unit Under Test (UUT)
   decrypting_entity uut(
			 .clk(clk), 
			 .rst(rst), 
			 .input_first_tdata(p), 
			 .input_first_tvalid(p_tvalid), 
//			 .input_first_tready(p_tready), 
			 .input_second_tdata(alpha), 
			 .input_second_tvalid(alpha_tvalid), 
//			 .input_second_tready(alpha_tready),
			 .output_a_tdata(p_out_tdata), 
			 .output_a_tvalid(p_out_tvalid), 
			 .output_a_tready(output_tready), 
			 .output_b_tdata(alpha_out_tdata), 
			 .output_b_tvalid(alpha_out_tvalid), 
			 .output_b_tready(output_tready),
			 .output_c_tdata(public_key), 
			 .output_c_tvalid(public_key_tvalid), 
			 .output_c_tready(output_tready)
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
      p = 64'd18446744073709551337;
      p_tvalid = 1;
      alpha = 64'd9223372036854775433;
      alpha_tvalid = 1;

      
      p_out_tready = 0;
      alpha_out_tready = 0;
      public_key_tready = 0;
      #5;
      p_out_tready = 1;
      alpha_out_tready = 1;
      public_key_tready = 1;
      
      // Wait 100 ns for global reset to finish
      #200;
      
      // Add stimulus here

   end
   
endmodule

