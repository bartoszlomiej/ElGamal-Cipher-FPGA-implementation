module mult_64_pipeline_2(
			  input wire 		    clk, rst,
			  input wire [31:0] input_a_tdata, input_b_tdata,
			  input wire 		    input_a_tvalid, input_b_tvalid,
			  output wire 		    input_a_tready, input_b_tready,
			  output wire [63:0]    output_tdata,
			  output wire 		    output_tvalid,
			  input wire 		    output_tready
			  );
   //'include "mult_32_pipeline_2.v";
   reg [63:0] 					    output_reg; 
   reg 						    calculate_e;
   
   wire [15:0] 					    input_a_high; //keeps the higher bits of input data
   wire [15:0] 					    input_a_low;  //keeps the lower bits of input data
   
   wire [15:0] 					    input_b_high;
   wire [15:0] 					    input_b_low;

   wire [15:0] 					    e_high_tdata, e_low_tdata;

   reg [31:0] 					    out_reg;
   reg [31:0] 					    bufer_reg;

   reg 						    rdy_flg;
   
   wire 					    a_output_tready, d_output_tready, e_output_tready;
   
   reg [31:0] 					    a, d, e;
   
   //assign output_tdata = output_reg; //this doesn't work with this
   assign {input_a_high, input_a_low} = input_a_tdata; // input A
   assign {input_b_high, input_b_low} = input_b_tdata; // input B

   assign e_high_tdata = input_a_high + input_b_high;
   assign e_low_tdata = input_a_low + input_b_low;
   
   mult_32_pipeline_2 mult_a(
			     .clk(clk),
			     .rst(rst),
			     .input_a_tdata(input_a_high),
			     .input_b_tdata(input_b_high),
			     .input_a_tvalid(input_a_tvalid),
			     .input_b_tvalid(input_b_tvalid),
			     .input_a_tready(a_high_tready),
			     .input_b_tready(a_low_tready),
			     .output_tdata(a),
			     .output_tvalid(a_output_tvalid),
			     .output_tready(a_output_tready)
			     );
   
   mult_32_pipeline_2 mult_d(
			     .clk(clk),
			     .rst(rst),
			     .input_a_tdata(input_a_low),
			     .input_b_tdata(input_b_low),
			     .input_a_tvalid(input_a_tvalid),
			     .input_b_tvalid(input_b_tvalid),
			     .input_a_tready(d_high_tready),
			     .input_b_tready(d_low_tready),
			     .output_tdata(d),
			     .output_tvalid(d_output_tvalid),
			     .output_tready(d_output_tready)
			     );
   
   mult_32_pipeline_2 mult_e(
			     .clk(clk),
			     .rst(rst),
			     .input_a_tdata(e_high_tdata),
			     .input_b_tdata(e_low_tdata),
			     .input_a_tvalid(e_high_tvalid),
			     .input_b_tvalid(e_low_tvalid),
			     .input_a_tready(e_high_tready),
			     .input_b_tready(e_low_tready),
			     .output_tdata(e),
			     .output_tvalid(e_output_tvalid),
			     .output_tready(e_output_tready)
			     );      
   //	 rdy_flg = 1b'0;
   
   
   always @(posedge clk) begin
      //	 karatsuba #(.SIZE(SIZE/2))(a...);
      //	 karatsuba #(.SIZE(SIZE/2))(d...);	 
      //	 karatsuba #(.SIZE(SIZE/2))(e...);
      //multiplication by 2^n is just assignment of the value to the high part of the register;
      assign calculate_e = a_output_tready & d_output_tready & e_output_tready;
      if(calculate_e) begin
	 if(rdy_flg == 2'b00) begin
	    out_reg <= a << (32);
	    bufer_reg <= d << (16);
	    e <= e - d - a;
	    rdy_flg <= 2'b01;
	 end
	 else if (rdy_flg == 2'b01) begin
	    out_reg <= out_reg + bufer_reg + e;
	    rdy_flg <= 2'b10;
	 end
	 else if (rdy_flg == 2'b10) begin
	    $display("I am actually useless.");
	    rdy_flg <= 2'b11;
	 end
      end
   end
endmodule
