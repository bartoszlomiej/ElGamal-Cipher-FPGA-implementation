module LFSR_tb;
   reg clk;
   reg rst;
   reg [63:0] seed;

   reg 	      input_ready;

   wire       output_valid;
   wire [63:0] rnd;

   LFSR uut (
	     .clk(clk), 
	     .rst(rst),
	     .input_tvalid(input_ready),
	     .seed(seed),
	     .output_tvalid(output_valid),
	     .rnd(rnd)
	     );
   
   initial begin
      clk = 0;
      forever
	#10 clk = ~clk;
   end
   
   initial begin
      seed = 64'hFFFFFFFFFFFFFFFF;
      input_ready = 1;
      rst = 1;
      #12;
      rst = 0;
      #100;
   end
endmodule
