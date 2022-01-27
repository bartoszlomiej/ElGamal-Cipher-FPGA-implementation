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
   
   reg [SIZE-1 : 0] 	     power = 1;
   reg [SIZE-1 : 0] 	     modulus;

   reg [SIZE-1 : 0] 	     output_reg = 1;
   wire [SIZE-1 : 0] 	     output_wire;
   reg 			     out_valid = 0;
   
   reg 			     data_read = 0;
   
   wire 		     input_rdy;
   wire 		     multiplicand_ready;
   wire 		     base_finished, result_finished;
   wire 		     base_ready, result_ready;
//   wire 		     base_ready;
   
   reg 			     reset = 0;
   wire 		     rst_mult;

   wire 		     power_lsb = ~power[0];
//   reg 			     power_lsb_reg = 1;
   
   assign output_tdata = output_reg;
   assign output_tvalid = out_valid;
   
   assign input_rdy = input_base_tvalid & input_power_tvalid & input_modulus_tvalid;
   assign input_base_tready = data_read & ~out_valid;
   
//   assign power_lsb = ~power_lsb_reg;
//   assign result_ended = result_finished | power_lsb;

   assign base_ready = power_lsb | multiplicand_ready;
   assign result_ready = power_lsb | result_finished;
   assign iteration_finished = (result_ready & base_finished) | (power_lsb & base_finished);
   assign rst_mult = reset;


   
   multiplication_modulo mult_result(
				     .clk(clk), 
				     .rst(rst_mult), 
				     .input_multiplier_tdata(output_reg),
				     .input_multiplier_tvalid(~power_lsb),
				     .input_multiplicand_tdata(base), 
				     .input_multiplicand_tvalid(~power_lsb),
				     .input_multiplicand_tready(multiplicand_ready),
				     .input_modulus_tdata(modulus), 
				     .input_modulus_tvalid(input_base_tready), 
				     .output_tdata(output_wire), 
				     .output_tvalid(result_finished), 
				     .output_tready(~power_lsb)
				     );

   multiplication_modulo mult_base(
				   .clk(clk), 
				   .rst(rst_mult), 
				   .input_multiplier_tdata(base), 
				   .input_multiplier_tvalid(base_ready),
				   .input_multiplicand_tdata(base), 
				   .input_multiplicand_tvalid(base_ready), 
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
	      base <= input_base_tdata;
	      power <= input_power_tdata;
	      modulus <= input_modulus_tdata;
	      if(input_rdy) data_read <= 1;
	   end else begin
	      if(iteration_finished) begin
		 base <= base_wire;
		 reset <= 1;
		 power <= power >> 1;		 
		 if(power > 0) begin
		    if(!power_lsb) output_reg <= output_wire;
		 end else begin
		    out_valid <= 1;
		 end
	      end
	   end
	   
	end // else: !if(rst)
	if(reset) reset <= 0;
     end

endmodule // mod_exp

