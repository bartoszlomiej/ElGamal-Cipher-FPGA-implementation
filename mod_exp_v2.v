`timescale 1ns / 1ps

module mod_exp #(parameter SIZE = 64)
   (
    input wire 		     clk, rst,
    // using AXI stream inputs
    wire [SIZE-1 : 0] 	     input_base_tdata,
    input wire 		     input_base_tvalid,
    output wire 	     input_base_tready,
   
    input wire [SIZE-1 : 0]  input_power_tdata,
    input wire 		     input_power_tvalid, 
    output wire 	     input_power_tready,
    // using AXI stream inputs
    wire [SIZE-1 : 0] 	     input_modulus_tdata,
    input wire 		     input_modulus_tvalid,
    output wire 	     input_modulus_tready,
    // using AXI stream outputs
    output wire [SIZE-1 : 0] output_tdata,
    output wire 	     output_tvalid, 
    input wire 		     output_tready
    );
   
   reg [SIZE-1 : 0] 	     base;
   wire [SIZE-1 : 0] 	     base_wire;
   
   reg [SIZE-1 : 0] 	     power;
   reg [SIZE-1 : 0] 	     modulus;

   reg [SIZE-1 : 0] 	     output_reg = 1;
   wire [SIZE-1 : 0] 	     output_wire;
   reg 			     out_valid;
   
   reg 			     data_read = 0;
   
   wire 		     input_rdy;
   wire 		     multiplicand_ready;
   wire 		     base_finished, result_finished;
//   wire 		     base_ready, result_ready;
   
   reg 			     reset = 0;
   wire 		     rst_mult;
   
   assign output_tdata = output_reg;
   
   assign input_rdy = input_base_tvalid & input_power_tvalid & input_modulus_tvalid;
   assign input_base_tready = data_read;

   assign iteration_finished = result_finished & base_finished;
   assign rst_mult = reset;
   
   multiplication_modulo mult_result(
				     .clk(clk), 
				     .rst(rst_mult), 
				     .input_multiplier_tdata(output_reg),
				     .input_multiplier_tvalid(input_base_tready),
				     .input_multiplicand_tdata(base), 
				     .input_multiplicand_tvalid(input_base_tready),
				     .input_multiplicand_tready(multiplicand_ready),
				     .input_modulus_tdata(modulus), 
				     .input_modulus_tvalid(input_base_tready), 
				     .output_tdata(output_wire), 
				     .output_tvalid(result_finished), 
				     .output_tready(input_base_tready)
				     );

   multiplication_modulo mult_base(
				   .clk(clk), 
				   .rst(rst_mult), 
				   .input_multiplier_tdata(base), 
				   .input_multiplier_tvalid(multiplicand_ready),
				   .input_multiplicand_tdata(base), 
				   .input_multiplicand_tvalid(multiplicand_ready), 
				   .input_modulus_tdata(modulus), 
				   .input_modulus_tvalid(input_base_tready), 
				   .output_tdata(base_wire), 
				   .output_tvalid(base_finished), 
				   .output_tready(input_base_tready)
				   );
   always @(posedge clk)
     begin
	if(rst) begin
	   base <= 0;
	   power <= 0;
	   modulus <= 0;
	   data_read <= 0;
	   reset <= 1;
	end else begin
	   if(data_read == 0) begin
	      base <= input_multiplier_tdata;
	      power <= input_multiplicand_tdata;
	      modulus <= input_modulus_tdata;
	      if(input_rdy) data_read <= 1;
	   end else begin
	      if(iteration_finished) begin
		 output_reg <= output_wire;
		 base <= base_wire;
		 reset <= 1;
	      end
	   end
	   
	end // else: !if(rst)
	if(reset) reset <= 0;
     end

endmodule // mod_exp

