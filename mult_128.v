//multiplication of two 64 bit numbers using Karutsuba algorithm

module mult_128(
		input wire 	    clk, rst,
		input wire [63:0]   input_a_tdata, input_b_tdata,
		input wire 	    input_a_tvalid, input_b_tvalid,
		output wire 	    input_a_tready, input_b_tready,
		output wire [127:0] output_tdata,
		output wire 	    output_tvalid,
		input wire 	    output_tready
		);

   wire 			    karatsuba_rdy;
   
   wire [31:0] 			    input_a_high; //keeps the higher bits of input data
   wire [31:0] 			    input_a_low;  //keeps the lower bits of input data
   
   wire [31:0] 			    input_b_high;
   wire [31:0] 			    input_b_low;

   wire [31:0] 			    e_high_tdata, e_low_tdata;

   reg [127:0] 			    output_reg;
   reg [95:0] 			    bufer_reg = 0;

   reg [2:0] 			    rdy_flg = 0;
   
   wire 			    data_tready;
   wire 			    a_output_tvalid, d_output_tvalid, e_output_tvalid;
   
   wire [63:0] 			    a, d, e;
   reg [63:0] 			    a_reg, d_reg, e_reg;
   
   assign {input_a_high, input_a_low} = input_a_tdata; // input A
   assign {input_b_high, input_b_low} = input_b_tdata; // input B

   assign e_high_tdata = input_a_high + input_a_low;
   assign e_low_tdata = input_b_high + input_b_low;
   
   assign input_a_tready = input_b_tvalid & output_tready;
   assign input_b_tready = input_a_tvalid & output_tready;
   
   assign data_tready = input_a_tready & input_b_tready & output_tready;
   assign karatsuba_rdy = a_output_tvalid & d_output_tvalid & e_output_tvalid;

   assign output_tvalid = rdy_flg[2];
   
   assign output_tdata = output_reg;
   
   mult_64_pipeline_2 mult_a(
			     .clk(clk),
			     .rst(rst),
			     .input_a_tdata(input_a_high),
			     .input_b_tdata(input_b_high),
			     .input_a_tvalid(input_a_tvalid),
			     .input_b_tvalid(input_b_tvalid),
			     //			     .input_a_tready(a_high_tready),
			     //			     .input_b_tready(a_low_tready),
			     .output_tdata(a),
			     .output_tvalid(a_output_tvalid),
			     .output_tready(data_tready)
			     );
   
   mult_64_pipeline_2 mult_d(
			     .clk(clk),
			     .rst(rst),
			     .input_a_tdata(input_a_low),
			     .input_b_tdata(input_b_low),
			     .input_a_tvalid(input_a_tvalid),
			     .input_b_tvalid(input_b_tvalid),
			     //			     .input_a_tready(d_high_tready),
			     //			     .input_b_tready(d_low_tready),
			     .output_tdata(d),
			     .output_tvalid(d_output_tvalid),
			     .output_tready(data_tready)
			     );
   
   mult_64_pipeline_2 mult_e(
			     .clk(clk),
			     .rst(rst),
			     .input_a_tdata(e_high_tdata),
			     .input_b_tdata(e_low_tdata),
			     .input_a_tvalid(input_a_tvalid),
			     .input_b_tvalid(input_b_tvalid),
			     //			     .input_a_tready(e_high_tready),
			     //			     .input_b_tready(e_low_tready),
			     .output_tdata(e),
			     .output_tvalid(e_output_tvalid),
			     .output_tready(data_tready)
			     );
   /* Pipelined version */

   always @(posedge clk) begin
      if(karatsuba_rdy) begin
	 if(rdy_flg[1:0] == 2'b00) begin
	    a_reg <= a;
	    e_reg <= e;
	    d_reg <= d;
	    rdy_flg <= 3'b001;
	 end	 
	 if(rdy_flg == 3'b001) begin
	    output_reg <= a_reg << (64);
	    e_reg <= e_reg - d_reg - a_reg;
	    rdy_flg <= 3'b10;
	 end
	 else if (rdy_flg == 3'b010) begin
	    bufer_reg <= e_reg << (32);
	    rdy_flg <= 3'b011;
	 end
	 else if (rdy_flg == 3'b011) begin
	    output_reg <= output_reg + bufer_reg + d_reg;	    
	    rdy_flg <= 3'b100;
	 end
      end // if (calculate_e)
   end
endmodule
