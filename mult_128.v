//multiplication of two 64 bit numbers using Karutsuba algorithm

module karatsuba_mult #(parameter SIZE = 128)(
				     input wire 	       clk, rst,
				     input wire [(SIZE/2)-1:0] input_a_tdata, input_b_tdata,
				     input wire 	       input_a_tvalid, input_b_tvalid,
				     output wire 	       input_a_tready, input_b_tready,
				     output wire [SIZE-1:0]    output_tdata,
				     output wire 	       output_tvalid,
				     input wire 	       output_tready
				     );

   reg [SIZE-1:0] 				output_reg;

   reg [(SIZE/4)-1:0] 				input_a_high; //keeps the higher bits of input data
   reg [(SIZE/4)-1:0] 				input_a_low;  //keeps the lower bits of input data
   
   reg [(SIZE/4)-1:0] 				input_b_high;
   reg [(SIZE/4)-1:0] 				input_b_low;

   reg [(SIZE/2)-1:0] 				out_reg;
   reg [(SIZE/2)-1:0] 				bufer_reg;

   reg 						rdy_flg;

   reg [(SIZE/2)-1:0] 				a, d, e;   
   
   wire 					calculate _e;
   wire 					a_output_tready, d_output_tready, e_output_tready;
   wire 					a_high_tvalid, a_low_tvalid, a_high_tready, a_low_tready, a_output_tvalid;
   wire 					d_high_tvalid, d_low_tvalid, d_high_tready, d_low_tready, d_output_tvalid;
   wire 					e_high_tvalid, e_low_tvalid, e_high_tready, e_low_tready, e_output_tvalid;   
   
   assign output_tdata = output_reg;

   generate
      if(SIZE <= 16) begin
	 mult_32_pipeline_2(
			    .clk(clk), 
			    .rst(rst), 
			    .input_a_tdata(input_a_tdata),
			    .input_a_tvalid(input_a_tvalid), 
			    .input_a_tready(input_a_tready), 
			    .input_b_tdata(input_b_tdata), 
			    .input_b_tvalid(input_b_tvalid), 
			    .input_b_tready(input_b_tready), 
			    .output_tdata(output_reg), 
			    .output_tvalid(output_tvalid), 
			    .output_tready(output_tready)
			    );
	 
      end // if (SIZE <= 16)
      else begin
	 assign input_a_tdata = {input_a_high, input_a_low}; // input A
	 assign input_b_tdata = {input_b_high, input_b_low}; // input B

	 assign e_high_tdata = input_a_high + input_b_high;
	 assign e_low_tdata = input_a_low + input_b_low;
	 
//      end // else: !if(SIZE <= 16)
	//	karatsuba #(.SIZE(SIZE/2))(a...);
      	karatsuba_mult multiply_a #(.SIZE(SIZE/2))(
		.clk(clk),
		.rst(rst),
		.input_a_tdata(input_a_high),
		.input_b_tdata(input_b_high),
		.input_a_tvalid(a_high_tvalid),
		.input_b_tvalid(a_low_tvalid),
		.input_a_tready(a_high_tready),
		.input_b_tready(a_low_tready),
		.output_tdata(a),
		.output_tvalid(a_output_tvalid),
		.output_tready(a_output_tready)
	);
      	karatsuba_mult multiply_d #(.SIZE(SIZE/2))(
		.clk(clk),
		.rst(rst),
		.input_a_tdata(input_a_low),
		.input_b_tdata(input_b_low),
		.input_a_tvalid(d_high_tvalid),
		.input_b_tvalid(d_low_tvalid),
		.input_a_tready(d_high_tready),
		.input_b_tready(d_low_tready),
		.output_tdata(d),
		.output_tvalid(d_output_tvalid),
		.output_tready(d_output_tready)
	);
      karatsuba_mult multiply_e #(.SIZE(SIZE/2))(
		.clk(clk),
		.rst(rst),
		.input_a_tdata(input_e_high),
		.input_b_tdata(input_e_low),
		.input_a_tvalid(e_high_tvalid),
		.input_b_tvalid(e_low_tvalid),
		.input_a_tready(e_high_tready),
		.input_b_tready(e_low_tready),
		.output_tdata(e),
		.output_tvalid(e_output_tvalid),
		.output_tready(e_output_tready)
	);      
      //	 karatsuba #(.SIZE(SIZE/2))(a...);
      //	 karatsuba #(.SIZE(SIZE/2))(d...);	 
      //	 karatsuba #(.SIZE(SIZE/2))(e...);
      end
   endgenerate      
   always @(posedge clk) begin
      //multiplication by 2^n is just assignment of the value to the high part of the register;
      assign calculate_e = a_output_tready & d_output_tready & e_output_tready;
      if(calculate_e) begin
	 if(rdy_flg == 2'b00) begin
	    out_reg <= a << (SIZE/2);
	    bufer_reg <= d << (SIZE/4);
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
/*
 `timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:37:45 01/13/2022 
// Design Name: 
// Module Name:    mult_128 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//multiplication of two 64 bit numbers using Karutsuba algorithm


module karatsuba_mult #(parameter SIZE = 64)(
				     input wire 	       clk, rst,
				     input wire [(SIZE/2)-1:0] input_a_tdata, input_b_tdata,
				     input wire 	       input_a_tvalid, input_b_tvalid,
				     output wire 	       input_a_tready, input_b_tready,
				     output wire [SIZE-1:0]    output_tdata,
				     output wire 	       output_tvalid,
				     input wire 	       output_tready
				     );
	//'include "mult_32_pipeline_2.v";
   reg [SIZE-1:0] 				output_reg; 
	reg						calculate_e;
	
	reg [(SIZE/4)-1:0] 				input_a_high; //keeps the higher bits of input data
	reg [(SIZE/4)-1:0] 				input_a_low;  //keeps the lower bits of input data
	 
	reg [(SIZE/4)-1:0] 				input_b_high;
	reg [(SIZE/4)-1:0] 				input_b_low;

	reg [(SIZE/2)-1:0] 				out_reg;
	reg [(SIZE/2)-1:0] 				bufer_reg;

	reg 									rdy_flg;
	 
	wire									a_output_tready, d_output_tready, e_output_tready;

   reg [(SIZE/2)-1:0] a, d, e;
	
   //assign output_tdata = output_reg; //this doesn't work with this
   generate
      if(SIZE <= 32) begin
			mult_32_pipeline_2 multiply(
			    .clk(clk), 
			    .rst(rst), 
			    .input_a_tdata(input_a_tdata),
			    .input_a_tvalid(input_a_tvalid), 
			    .input_a_tready(input_a_tready), 
			    .input_b_tdata(input_b_tdata), 
			    .input_b_tvalid(input_b_tvalid), 
			    .input_b_tready(input_b_tready), 
			    .output_tdata(output_tdata), 
			    .output_tvalid(output_tvalid), 
			    .output_tready(output_tready)
			    );
      end // if (SIZE <= 16)
      else begin		
	 assign input_a_tdata = {input_a_high, input_a_low}; // input A
	 assign input_b_tdata = {input_b_high, input_b_low}; // input B

	 assign e_high_tdata = input_a_high + input_b_high;
	 assign e_low_tdata = input_a_low + input_b_low;
	 
//      end // else: !if(SIZE <= 16)
	//	karatsuba #(.SIZE(SIZE/2))(a...);
      	karatsuba_mult mult_a #(.SIZE(SIZE/2))(
		.clk(clk),
		.rst(rst),
		.input_a_tdata(input_a_high),
		.input_b_tdata(input_b_high),
		.input_a_tvalid(a_high_tvalid),
		.input_b_tvalid(a_low_tvalid),
		.input_a_tready(a_high_tready),
		.input_b_tready(a_low_tready),
		.output_tdata(a),
		.output_tvalid(a_output_tvalid),
		.output_tready(a_output_tready)
	);
      	karatsuba_mult mult_d #(.SIZE(SIZE/2))(
		.clk(clk),
		.rst(rst),
		.input_a_tdata(input_a_low),
		.input_b_tdata(input_b_low),
		.input_a_tvalid(d_high_tvalid),
		.input_b_tvalid(d_low_tvalid),
		.input_a_tready(d_high_tready),
		.input_b_tready(d_low_tready),
		.output_tdata(d),
		.output_tvalid(d_output_tvalid),
		.output_tready(d_output_tready)
	);
      karatsuba_mult mult_e #(.SIZE(SIZE/2))(
		.clk(clk),
		.rst(rst),
		.input_a_tdata(input_e_high),
		.input_b_tdata(input_e_low),
		.input_a_tvalid(e_high_tvalid),
		.input_b_tvalid(e_low_tvalid),
		.input_a_tready(e_high_tready),
		.input_b_tready(e_low_tready),
		.output_tdata(e),
		.output_tvalid(e_output_tvalid),
		.output_tready(e_output_tready)
	);      

//	 rdy_flg = 1b'0;
      end // else: !if(SIZE <= 16)
   endgenerate 
	
	
   always @(posedge clk) begin
      //	 karatsuba #(.SIZE(SIZE/2))(a...);
      //	 karatsuba #(.SIZE(SIZE/2))(d...);	 
      //	 karatsuba #(.SIZE(SIZE/2))(e...);
      //multiplication by 2^n is just assignment of the value to the high part of the register;
      assign calculate_e = a_output_tready & d_output_tready & e_output_tready;
      if(calculate_e) begin
	 if(rdy_flg == 2'b00) begin
	    out_reg <= a << (SIZE/2);
	    bufer_reg <= d << (SIZE/4);
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
endmodule // unmatched end(function|task|module|primitive|interface|package|class|clocking)
*/
