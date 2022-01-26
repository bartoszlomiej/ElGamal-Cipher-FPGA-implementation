`timescale 1ns / 1ps

module multiplication_modulo #(parameter SIZE = 64)
   (
    input wire 		     clk, rst,
    // using AXI stream inputs
    wire [SIZE-1 : 0] 	     input_multiplier_tdata,
    input wire 		     input_multiplier_tvalid,
    output wire 	     input_multiplier_tready,
   
    input wire [SIZE-1 : 0]  input_multiplicand_tdata,
    input wire 		     input_multiplicand_tvalid, 
    output wire 	     input_multiplicand_tready,
    // using AXI stream inputs
    wire [SIZE-1 : 0] 	     input_modulus_tdata,
    input wire 		     input_modulus_tvalid,
    output wire 	     input_modulus_tready,
    // using AXI stream outputs
    output wire [SIZE-1 : 0] output_tdata,
    output wire 	     output_tvalid, 
    input wire 		     output_tready
    );
   
   reg [SIZE-1 : 0] 	     multiplier = 0;
   reg [SIZE-1 : 0] 	     multiplicand = 0;
   reg [SIZE-1 : 0] 	     modulus = 0;

   reg [SIZE-1 : 0] 	     output_reg;
   reg [(SIZE*2)-1 : 0]      mult_output_reg;
   wire [(SIZE*2)-1 : 0]     mult_output_wire;
   wire [SIZE-1 : 0] 	     output_wire;
   reg 			     out_valid;

   wire 		     switch;
   wire 		     output_rdy;

   reg 			     mod_rdy = 0;

   reg 			     data_read = 0;
   
   wire 		     input_rdy;
   wire 		     input_read;

   
   assign input_rdy = output_tready & (!switch) & (!rst) & data_read;
   assign input_read = input_multiplier_tvalid & input_multiplicand_tvalid & input_modulus_tvalid;
   
   assign output_tvalid = out_valid & (!rst);
   assign output_tdata = output_reg;
   assign input_multiplicand_tready = data_read;
   
   mult_128 mult(
		 .clk(clk),
		 .rst(rst),
		 .input_a_tdata(multiplier),
		 .input_b_tdata(multiplicand),
		 .input_a_tvalid(input_rdy),
		 .input_b_tvalid(input_rdy),
		 .output_tdata(mult_output_wire),
		 .output_tvalid(switch),
		 .output_tready(input_rdy)
		 );

   modulo mod(
	      .clk(clk), 
	      .rst(rst), 
	      .input_dividen_tdata(mult_output_reg),
	      .input_dividen_tvalid(mod_rdy), 
	      //			       .input_dividen_tready(dividen_tready), 
	      .input_divisor_tdata(modulus), 
	      .input_divisor_tvalid(mod_rdy), 
	      //			       .input_divisor_tready(divisor_tready), 
	      .output_tdata(output_wire), 
	      .output_tvalid(output_rdy), 
	      .output_tready(output_valid)
	      );
   
   always @(posedge clk)
     begin
	if(rst) begin
	   multiplier <= 0;
	   multiplicand <= 0;
	   modulus <= 0;
	   out_valid <= 0;
	   mult_output_reg <= 0;
	   data_read <= 0;
	   output_reg <= 0;
	   mod_rdy <= 0;
	end else begin
	   if(data_read == 0) begin
	      multiplier <= input_multiplier_tdata;
	      multiplicand <= input_multiplicand_tdata;
	      modulus <= input_modulus_tdata;
	      if(input_read) data_read <= 1;
	   end else if(switch) begin
	      if(mod_rdy == 0) begin
		 mult_output_reg <= mult_output_wire;
		 mod_rdy <= 1;
	      end

	   end
	   if(output_rdy) begin
	      output_reg <= output_wire;
	      out_valid <= 1;
	   end
	end
     end
endmodule
