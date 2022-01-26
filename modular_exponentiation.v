`timescale 1ns / 1ps

/*
 * TODO:
 * assign AXI stream outputs and inputs to make any sens out of it.
 */

module modular_exponentiation #(parameter SIZE = 128)
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
   reg [SIZE-1 : 0] 	     power;
   reg [SIZE-1 : 0] 	     modulus;

   reg [SIZE-1 : 0] 	     output_reg;
   reg 			     out_valid;
   
   reg 			     state = 0;
   reg 			     switch = 0; //switch between calculation of multiplication and modulo
 			     

   wire 		     input_rdy = input_dividen_tvalid & input_divisor_tvalid & input_modulus_tvalid;
   wire 		     next_iteration;
   

   assign output_tdata = output_reg;
   
   
   always @(posedge clk)
     begin
	if(rst) begin
	   base <= 0;
	   power <= 0;

	   output_reg <= 0;
	   out_valid <= 0;
	end else begin
	   if(state == 0) begin
	      if(input_rdy) begin
		 base <= input_base_tdata;
		 power <= input_power_tdata;
		 
		 state <= 1;
	      end
	   end else if (state == 1) begin
	      if(power[0] == 1) begin
		 if(switch == 0) begin
		    mult_128 mult(
				  .clk(clk),
				  .rst(rst),
				  .input_a_tdata(output_reg),
				  .input_b_tdata(base),
				  .input_a_tvalid(state),
				  .input_b_tvalid(state),
				  .output_tdata(output_reg),
				  .output_tvalid(switch),
				  .output_tready(state)
				  );
		 end else begin
		    modulo mod(
			       .clk(clk), 
			       .rst(rst), 
			       .input_dividen_tdata(output_reg), 
			       .input_dividen_tvalid(state), 
			       .input_divisor_tdata(modulus), 
			       .input_divisor_tvalid(state), 
			       .output_tdata(output_reg), 
			       .output_tvalid(next_iteration), 
			       .output_tready(state)
			       );
		    if(next_iteration)
		      
		 end
		      
	      end
	   end
	end
     end

endmodule
