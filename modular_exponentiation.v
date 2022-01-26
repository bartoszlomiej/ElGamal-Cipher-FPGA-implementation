`timescale 1ns / 1ps

/*
 * TODO:
 * assign AXI stream outputs and inputs to make any sens out of it.
 */

module modular_exponentiation #(parameter SIZE = 64)
   (
    input wire 			 clk, rst,
    // using AXI stream inputs
    wire [SIZE-1 : 0] 		 input_base_tdata,
    input wire 			 input_base_tvalid,
    output wire 		 input_base_tready,
   
    input wire [SIZE-1 : 0] 	 input_power_tdata,
    input wire 			 input_power_tvalid, 
    output wire 		 input_power_tready,
    // using AXI stream inputs
    wire [SIZE-1 : 0] 	 input_modulus_tdata,
    input wire 			 input_modulus_tvalid,
    output wire 		 input_modulus_tready,
    // using AXI stream outputs
    output wire [SIZE-1 : 0] output_tdata,
    output wire 		 output_tvalid, 
    input wire 			 output_tready
    );
   
   reg [SIZE-1 : 0] 		 base;
//   reg [(SIZE*2)-1 : 0] 	 base_buffer;
   wire [SIZE-1 : 0] 	 base_wire;
   
   reg [SIZE-1 : 0] 	     power;
   reg [SIZE-1 : 0] 	     modulus;

   reg [SIZE-1 : 0]      output_reg = 1;
//   reg [SIZE-1 : 0] 	     buffer_reg = 1;
   wire [SIZE-1 : 0] 	 output_wire;
   
   reg 			     out_valid;
   
   reg 			     state = 0;
   
   wire 		     mult_output_rdy;
   wire 		     mult_base_rdy;

   wire 		     mult_output_input_rdy;
   reg 			     out_reg_rdy;
   
   wire 		     input_rdy;
   reg 			     rdy = 0;
   reg 			     base_rdy = 0;   
   reg 			     mult_output_rst = 0;
   reg 			     mult_base_rst = 0;
   reg 			     save_output = 1;
   reg 			     save_base = 1;
   
   assign output_tdata = output_reg;
   assign input_rdy = input_base_tvalid & input_power_tvalid & input_modulus_tvalid;

   assign mult_output_input_rdy = power[0] & mult_output_rdy;
   
   multiplication_modulo mult_output(
				     .clk(clk), 
				     .rst(mult_output_rst), 
				     .input_multiplier_tdata(output_reg),
				     .input_multiplier_tvalid(out_reg_rdy), 
				     .input_multiplicand_tdata(base), 
				     .input_multiplicand_tvalid(out_reg_rdy), 
				     .input_modulus_tdata(modulus), 
				     .input_modulus_tvalid(input_rdy), 
				     .output_tdata(output_wire), 
				     .output_tvalid(mult_output_rdy), 
				     .output_tready(rdy)
				     );

   multiplication_modulo mult_base(
				   .clk(clk), 
				   .rst(mult_base_rst
), 
				   .input_multiplier_tdata(base), 
				   .input_multiplier_tvalid(base_rdy), 
				   .input_multiplicand_tdata(base), 
				   .input_multiplicand_tvalid(base_rdy), 
				   .input_modulus_tdata(modulus), 
				   .input_modulus_tvalid(input_rdy), 
				   .output_tdata(base_wire), 
				   .output_tvalid(mult_base_rdy), 
				   .output_tready(base_rdy)
				   );   
   
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
		 modulus <= input_modulus_tdata;
		 out_reg_rdy <=1;
		 
		 if(out_reg_rdy) begin
		    state <= 1;
		    base_rdy <= 0;		 		 
		    rdy <= 1;
		 end

	      end
	   end else if (state == 1) begin
	      if(power >= 0) begin
		 if(mult_output_rdy == 1) begin
		    if(save_output == 1) begin
		       output_reg <= output_wire;
		       rdy <= 0;
		       base_rdy <= 1;
		       mult_output_rst <= 1;
		       save_output <= 0;
		       save_base <= 1;
		    end
		 end
//		 if(mult_output_rst == 1) mult_output_rst <= 0;
		 
		 if(mult_base_rdy == 1)
		   begin
		      if(save_base == 1) begin
			 base <= base_wire;
			 power <= power >> 1;
			 if(base_rdy) begin
			    base_rdy <= 0;
			    rdy <= 1;	
			    mult_base_rst <= 1;
			    mult_output_rst <= 0;
			 end
//			 if(mult_base_rst == 1) begin
//			   mult_base_rst <= 0;
			    save_base <= 0;
			    save_output <= 1; //this might be an issue
//			 end
		      end
		   end

	      end // if (power >= 0)
	      else begin
		 rdy <= 0;
		 base_rdy <= 0;

		 out_valid <= 1;
	      end
	   end
	end
     end
endmodule
