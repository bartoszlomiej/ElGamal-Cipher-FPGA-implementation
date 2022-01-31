`timescale 1ns / 1ps

module mult_inverse #(parameter SIZE = 64)
   (
    input wire 		     clk, rst,
    // using AXI stream inputs
    wire signed [SIZE-1 : 0] input_base_tdata,
    input wire 		     input_base_tvalid,
    output wire 	     input_base_tready,
   
    // using AXI stream inputs
    wire signed [SIZE-1 : 0] input_modulus_tdata,
    input wire 		     input_modulus_tvalid,
    output wire 	     input_modulus_tready,
    // using AXI stream outputs
    output wire [SIZE-1 : 0] output_tdata,
    output wire 	     output_tvalid, 
    input wire 		     output_tready
    );
   
   reg signed [SIZE-1 : 0] 	     x1;
   reg signed [SIZE-1 : 0] 	     x2;
   wire signed [SIZE-1 : 0] 	     x2_wire;
   
   reg signed [SIZE-1 : 0] 	     u;
   reg signed [SIZE-1 : 0] 	     v;
   
   //   reg [SIZE-1 : 0] 	     quotient;
   //   wire [SIZE-1 : 0] 	     quotient_wire;
   
   reg signed [SIZE-1 : 0] 	     modulus;

   reg 			     data_read = 0;
   reg 			     out_valid;
   reg signed [SIZE-1 : 0] 	     output_reg;

   reg [1:0] 		     state;

   reg 			     reset;
   
   //   reg [0 : 1] 		     state;
   //   wire 		     t_ready, r_ready, div_ready;
   //   wire 		     iteration_finished;
   /*
    division div_r(
    .clk(clk), 
    .rst(rst_div),
    .input_dividen_tdata(r),
    .input_dividen_tvalid(div_valid),
    .input_dividen_tready(),
    .input_divisor_tdata(new_r),
    .input_divisor_tvalid(div_valid),
    .input_divisor_tready(),
    .output_tdata(quotient_wire),
    .output_tvalid(div_ready),
    .output_tready(div_valid)
    );
    
    multiplication_modulo mult_t(
    .clk(clk), 
    .rst(rst_mult), 
    .input_multiplier_tdata(quotient),
    .input_multiplier_tvalid(t_valid),
    //				.input_multiplier_tready(),
    .input_multiplicand_tdata(new_t), 
    .input_multiplicand_tvalid(t_valid),
    .input_modulus_tdata(modulus), 
    .input_modulus_tvalid(input_rdy), 
    .output_tdata(t_wire), 
    .output_tvalid(t_ready), 
    .output_tready()
    );

    multiplication_modulo mult_r(
    .clk(clk), 
    .rst(rst_mult), 
    .input_multiplier_tdata(quotient), 
    .input_multiplier_tvalid(r_valid),
    //				.input_multiplier_tready(),				
    .input_multiplicand_tdata(new_r), 
    .input_multiplicand_tvalid(r_valid), 
    .input_modulus_tdata(modulus), 
    .input_modulus_tvalid(input_rdy), 
    .output_tdata(r_wire), 
    .output_tvalid(r_ready), 
    .output_tready(r_valid)
    );


    
    assign input_rdy = data_read;
    
    assign div_valid = state[1] & ~state[0];
    assign t_valid = ~state[1] & state[0];
    assign r_valid = ~state[1] & state[0];
    assign iteration_finished = t_ready & r_ready;
    assign rst_div = reset;
    assign rst_mult = reset;
    assign output_tvalid = out_valid;
    assign output_tdata = t;
    */

   reg 			     start_mod;
   wire 		     rst_mod;
   wire 		     mod_rdy, mod_finished;
   wire 		     input_read;

   reg 			     u_rdy_reg, v_rdy_reg;
   wire 		     u_rdy_wire, v_rdy_wire, finish;

   assign output_tvalid = out_valid;
//   assign output_tdata = t;   
   assign output_tdata = output_reg;
   
   assign mod_rdy = start_mod;
   assign input_read = input_base_tvalid & input_modulus_tvalid;

   assign u_rdy_wire = u_rdy_reg;
   assign v_rdy_wire = v_rdy_reg;
   assign finish = u_rdy_wire & v_rdy_wire;
   
   /*
   modulo_eq new_t_mod_m(
			 .clk(clk), 
			 .rst(rst_mod), 
			 .input_dividen_tdata(new_t),
			 .input_dividen_tvalid(mod_rdy), 
			 //			       .input_dividen_tready(dividen_tready), 
			 .input_divisor_tdata(modulus), 
			 .input_divisor_tvalid(mod_rdy), 
			 //			       .input_divisor_tready(divisor_tready), 
			 .output_tdata(new_t_wire), 
			 .output_tvalid(mod_finished), 
			 .output_tready(mod_rdy)
			 );
   */
   always @(posedge clk)
     begin
	if(rst) begin
	   modulus <= 0;
	   data_read <= 0;
	   reset <= 1;
	   state <= 2'b00;
	end
	if(data_read == 0) begin
	   u <= input_base_tdata;
	   v <= input_modulus_tdata;
	   x1 <= 1;
	   x2 <= 0;
	   modulus <= input_modulus_tdata;
	   u_rdy_reg <= 0;
	   v_rdy_reg <= 0;

	   state <= 2'b01;	   
	   reset <= 0;
	   if(input_read) data_read <= 1;
	end else if(!finish) begin
	   if(u == 1) u_rdy_reg <= 1;
	   else if(v == 1) v_rdy_reg <= 1;
	   else begin
	      if(state == 2'b01) begin
		 if(!u[0]) begin
		    u <= u >> 1;
		    if(!x1[0]) x1 <= x1 >>> 1;
		    else x1 <= (x1 + modulus) >>> 1;
		 end else state <= 2'b10;
	      end else if (state == 2'b10) begin
		 if(!v[0]) begin
		    v <= v >> 1;
		    if(!x2[0]) x2 <= x2 >>> 1;
		    else x2 <= (x2 + modulus) >>> 1;
		 end else state <= 2'b11;
	      end else if (state == 2'b11) begin
		 if(u >= v) begin
		    u <= u - v;
		    x1 <= x1 - x2;
		 end else begin
		    v <= v - u;
		    x2 <= x2 - x1;
		 end
		 state <= 2'b01;
	      end
	   end // else: !if(v == 1)
	end // if (!finish)
	if(u == 1) output_reg <= x1;
	else output_reg <= x2;
	out_valid <= 1;
	if(reset) reset <= 0;
     end // always @ (posedge clk)
endmodule
