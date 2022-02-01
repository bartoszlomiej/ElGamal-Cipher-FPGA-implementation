`timescale 1ns / 1ps

module encrypting_entity_tb #(parameter SIZE = 64);

   // Inputs
   reg clk;
   reg rst;
   reg [SIZE-1 : 0] p; //just for dbg - size
   reg 		    p_tvalid;
   reg [SIZE-1 : 0] a_key;
   reg 		    a_key_tvalid;
   reg [SIZE-1 : 0] m;
   reg 		    m_tvalid;

   // Outputs
   wire [SIZE-1 : 0] public_key_tdata;
   wire 	     public_key_tvalid;
   reg 		     public_key_tready;
   
   wire [SIZE-1 : 0] cryptogram_tdata;
   wire 	     cryptogram_tvalid;   
   reg 		     cryptogram_tready;
   
   wire 	     output_tready;

   assign output_tready = public_key_tready & cryptogram_tready;

   // Instantiate the Unit Under Test (UUT)
   encrypting_entity uut(
			 .clk(clk), 
			 .rst(rst), 
			 .input_p_tdata(p), 
			 .input_p_tvalid(p_tvalid), 
			 .input_a_key_tdata(a_key), 
			 .input_a_key_tvalid(a_key_tvalid),
			 .input_m_tdata(m), 
			 .input_m_tvalid(m_tvalid), 
			 .output_a_tdata(public_key_tdata), 
			 .output_a_tvalid(public_key_tvalid), 
			 .output_a_tready(output_tready), 
			 .output_b_tdata(cryptogram_tdata), 
			 .output_b_tvalid(cryptogram_tvalid), 
			 .output_b_tready(output_tready)
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
      a_key = 64'd1276454389566241996;
      a_key_tvalid = 1;

      m = 64'd98154719832413245;
      m_tvalid = 1;

      
      public_key_tready = 0;
      cryptogram_tready = 0;
      #5;
      public_key_tready = 1;
      cryptogram_tready = 1;
      
      // Wait 100 ns for global reset to finish
      #200;
      
      // Add stimulus here

   end
   
endmodule

