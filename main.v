module main(
	    input wire 	clk, rst,
	    input wire 	start,
	    output wire finish
	    );
   
   reg [63:0] 		input_a_tdata;
   reg [63:0] 		input_b_tdata;
   wire [127:0] 	result;
   reg [127:0] 		result_reg;

   assign result = result_reg;

   mult_128 test(
		 .clk(clk),
		 .rst(rst),
		 .input_a_tdata(input_a_tdata),
		 .input_b_tdata(input_b_tdata),
		 .input_a_tvalid(start),
		 .input_b_tvalid(start),
		 //			     .input_a_tready(e_high_tready),
		 //			     .input_b_tready(e_low_tready),
		 .output_tdata(result),
		 .output_tvalid(finish),
		 .output_tready(start)
		 );
   
   always @(posedge clk) begin
      if(start) begin
	 input_a_tdata <= 64'd123123124443096802;
	 input_b_tdata <= 64'd314141255378583275;
      end
   end
endmodule

