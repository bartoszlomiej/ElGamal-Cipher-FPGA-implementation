module mult_64_pipeline_2(
			  input wire 	     clk, rst,
			  input wire [31:0]  input_a_tdata, input_b_tdata,
			  input wire 	     input_a_tvalid, input_b_tvalid,
			  output wire 	     input_a_tready, input_b_tready,
			  output wire [63:0] output_tdata,
			  output wire 	     output_tvalid,
			  input wire 	     output_tready
			  );
   //'include "mult_32_pipeline_2.v";
   reg [63:0] 					    output_reg; 
   wire 					    karatsuba_rdy;
   
   wire [15:0] 					    input_a_high; //keeps the higher bits of input data
   wire [15:0] 					    input_a_low;  //keeps the lower bits of input data
   
   wire [15:0] 					    input_b_high;
   wire [15:0] 					    input_b_low;

   wire [15:0] 					    e_high_tdata, e_low_tdata;

   reg [63:0] 					    out_reg;
   reg [63:0] 					    bufer_reg;

   reg [2:0] 					    rdy_flg = 0;
   
   wire 					    data_tready;
   wire 					    a_output_tvalid, d_output_tvalid, e_output_tvalid;
   
   wire [31:0] 					    a, d, e;
   reg [31:0] 					    a_reg, d_reg, e_reg;
   
   //assign output_tdata = output_reg; //this doesn't work with this
   assign {input_a_high, input_a_low} = input_a_tdata; // input A
   assign {input_b_high, input_b_low} = input_b_tdata; // input B

   assign e_high_tdata = input_a_high + input_a_low;
   assign e_low_tdata = input_b_high + input_b_low;
   
   assign input_a_tready = input_b_tvalid & output_tready;
   assign input_b_tready = input_a_tvalid & output_tready;
   
   assign data_tready = input_a_tready & input_b_tready & output_tready;
   assign karatsuba_rdy = a_output_tvalid & d_output_tvalid & e_output_tvalid;

   assign output_tvalid = rdy_flg[2];
   
   assign output_tdata = out_reg;
	
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
			     .output_tready(data_tready)
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
			     .output_tready(data_tready)
			     );
   
   mult_32_pipeline_2 mult_e(
			     .clk(clk),
			     .rst(rst),
			     .input_a_tdata(e_high_tdata),
			     .input_b_tdata(e_low_tdata),
			     .input_a_tvalid(input_a_tvalid),
			     .input_b_tvalid(input_b_tvalid),
			     .input_a_tready(e_high_tready),
			     .input_b_tready(e_low_tready),
			     .output_tdata(e),
			     .output_tvalid(e_output_tvalid),
			     .output_tready(data_tready)
			     );
   /* Pipelined version */

   always @(negedge clk) begin
      if(karatsuba_rdy) begin
	 if(rdy_flg[1:0] == 2'b00) begin
	    a_reg <= a;
	    e_reg <= e;
	    d_reg <= d;
	    rdy_flg <= 3'b001;
	 end
      end
   end

   always @(posedge clk) begin
      if(karatsuba_rdy) begin
	 if(rdy_flg == 3'b001) begin
	    out_reg <= a_reg << (32);
	    e_reg <= e_reg - d_reg - a_reg;
	    rdy_flg <= 3'b10;
	 end
	 else if (rdy_flg == 3'b010) begin
	    bufer_reg <= e_reg << (16);
	    rdy_flg <= 3'b011;
	 end
	 else if (rdy_flg == 3'b011) begin
	    out_reg <= out_reg + bufer_reg + d_reg;	    
	    rdy_flg <= 3'b100;
	 end
      end // if (calculate_e)
   end
endmodule   
/*
   always @(posedge clk) begin
      //	 karatsuba #(.SIZE(SIZE/2))(a...);
      //	 karatsuba #(.SIZE(SIZE/2))(d...);	 
      //	 karatsuba #(.SIZE(SIZE/2))(e...);
      //multiplication by 2^n is just assignment of the value to the high part of the register;
      assign calculate_e = a_output_tready & d_output_tready & e_output_tready;
      if(calculate_e) begin
	 if(rdy_flg == 2'b00) begin
	    $display("Hey:).");
	    out_reg <= a_reg << (32);
	    bufer_reg <= d_reg << (16);
 e_reg <= e_reg - d_reg - a_reg;
	    rdy_flg <= 2'b01;
	 end
	 else if (rdy_flg == 2'b01) begin
	    out_reg <= out_reg + bufer_reg + e_reg;
	    rdy_flg <= 2'b10;
	 end
	 else if (rdy_flg == 2'b10) begin
	    $display("I am actually useless.");
	    rdy_flg <= 2'b11;
	 end
      end // if (calculate_e)
      else rdy_flg <= 2'b00;
   end
endmodule
*/
