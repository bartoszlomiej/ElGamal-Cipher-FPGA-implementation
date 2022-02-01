`timescale 1ns / 1ps

module mult_inverse #(parameter SIZE = 64)
   (
    input wire 		     clk, rst,
    // using AXI stream inputs
    wire [SIZE-1 : 0] 	     input_base_tdata,
    input wire 		     input_base_tvalid,
    output wire 	     input_base_tready,
   
    // using AXI stream inputs
    wire [SIZE-1 : 0] 	     input_modulus_tdata,
    input wire 		     input_modulus_tvalid,
    output wire 	     input_modulus_tready,
    // using AXI stream outputs
    output wire [SIZE-1 : 0] output_tdata,
    output wire 	     output_tvalid, 
    input wire 		     output_tready
    );
   
//   reg [SIZE-1 : 0] 	     base;

   reg [SIZE-1 : 0] 	     t;
   reg [SIZE-1 : 0] 	     new_t;
   wire [SIZE-1 : 0] 	     t_wire;
   
   reg [SIZE-1 : 0] 	     r;
   reg [SIZE-1 : 0] 	     new_r;
   wire [SIZE-1 : 0] 	     r_wire;
   
   reg [SIZE-1 : 0] 	     quotient;
   wire [SIZE-1 : 0] 	     quotient_wire;
   
   reg [SIZE-1 : 0] 	     modulus;

   reg [SIZE-1 : 0] 	     output_reg = 1;
   wire [SIZE-1 : 0] 	     output_wire;
   reg 			     out_valid = 0;
   
   reg 			     data_read = 0;

   wire 		     input_rdy;

   reg 			     new_r_empty_reg;
   wire 		     new_r_empty;
   
   wire 		     t_valid;
   wire 		     t_ready;
   reg 			     t_ready_reg;
   
   wire 		     r_valid;
   wire 		     r_ready;
   reg 			     r_ready_reg;
   
   wire 		     modulus_read;

   wire 		     div_valid;   
   wire 		     div_ready;

   wire 		     iteration_finished;

   reg 			     reset;
   wire 		     rst_div;
   wire 		     rst_mult;

   reg 			     quotient_rdy_reg;
   wire 		     quotient_rdy;

   assign input_rdy = input_base_tvalid & input_modulus_tvalid;

//   assign new_r_empty = new_r_empty_reg;
   assign modulus_read = data_read;

   assign div_valid = data_read & (~rst_div);
//   assign div_valid = (r_ready & t_ready) | input_rdy;// & (~new_r_empty);
   assign t_valid = div_ready & quotient_rdy;// & (~new_r_empty);
   assign r_valid = div_ready & quotient_rdy;// & (~new_r_empty);

   assign quotient_rdy = quotient_rdy_reg;
   
   assign iteration_finished = t_ready & r_ready;
//   assign rst_div = iteration_finished;//quotient_t_ready & quotient_r_ready;
   

   assign output_tdata = output_reg;
   assign output_tvalid = out_valid;
   assign rst_div = reset;
   assign rst_mult = reset;
   
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
				.input_multiplier_tready(quotient_t_ready),
				.input_multiplicand_tdata(new_t), 
				.input_multiplicand_tvalid(t_valid),
				.input_modulus_tdata(modulus), 
				.input_modulus_tvalid(modulus_read), 
				.output_tdata(t_wire), 
				.output_tvalid(t_ready), 
				.output_tready(t_valid & quotient_t_ready)
				);

   multiplication_modulo mult_r(
				.clk(clk), 
				.rst(rst_mult), 
				.input_multiplier_tdata(quotient), 
				.input_multiplier_tvalid(r_valid),
				.input_multiplier_tready(quotient_r_ready),				
				.input_multiplicand_tdata(new_r), 
				.input_multiplicand_tvalid(r_valid), 
				.input_modulus_tdata(modulus), 
				.input_modulus_tvalid(modulus_read), 
				.output_tdata(r_wire), 
				.output_tvalid(r_ready), 
				.output_tready(r_valid)
				);
   always @(posedge clk)
     begin
	if(rst) begin
	   modulus <= 0;
	   data_read <= 0;
	   reset <= 1;
	end else begin
	   if(data_read == 0) begin
	      new_r <= input_base_tdata;
	      r <= input_modulus_tdata;
	      t <= 0;
	      new_t <= 1;
	      modulus <= input_modulus_tdata;
	      quotient_rdy_reg <= 0;

	      reset <= 0;
	      if(input_rdy) data_read <= 1;
	   end else begin
	      if(new_r) begin
		 if(r < new_r) begin
		    t <= new_t;
		    new_t <= t;
		    r <= new_r;
		    new_r <= r;
		    reset <= 1;
		 end
		 else begin
		    quotient_rdy_reg <= 1;
		    if(div_ready) quotient <= quotient_wire;
		    if(iteration_finished) begin
		       t <= new_t;
		       new_t <= t - t_wire;
		       r <= new_r;
		       new_r <= r - r_wire;
		       
		       reset <= 1;
		    end
		 end // else: !if(r < new_r)
	      end // if (new_r)
	      else begin
		 if(r) begin
		    $display("not invertible");
		 end
		 if(t < 0) t <= t + modulus;
		 else begin
		    output_reg <= t;
		    out_valid <= 1;
		 end
	      end // else: !if(data_read == 0)
	   end
	end // else: !if(rst)
	if(reset) reset <= 0;
     end

endmodule // mod_exp   	      
/*		 
		 if(div_ready) begin
		    quotient <= quotient_wire;
		    if(!quotient) begin
		       t <= new_t;
		       new_t <= t;
		       r <= new_r;
		       new_r <= r;
		       quotient_rdy_reg <= 1;
		    end else quotient_rdy_reg <= 0;
		 end
		 if(iteration_finished) begin
		    t <= new_t;
		    new_t <= t - t_wire;
		    r <= new_r;
		    new_r <= r - r_wire;
		    
		    reset <= 1;
		 end
	      end else begin // if (new_r)
		 if(r) begin
		    $display("not invertible");
		 end
		 if(t < 0) t <= t + modulus;
		 else begin
		    output_reg <= t;
		    out_valid <= 1;
		 end
		 
	      end
	   end
	   
	end // else: !if(rst)
		 */

/*   
   always @(posedge clk)
     begin
	if(rst) begin
//	   base <= 0;
	   modulus <= 0;
	   data_read <= 0;
	   reset <= 1;
	end else begin
	   if(data_read == 0) begin
	      new_r <= input_base_tdata;
	      r <= input_modulus_tdata;
	      t <= 0;
	      new_t <= 1;
	      modulus <= input_modulus_tdata;
	      quotient_rdy_reg <= 0;

//	      new_r_empty <= 0; //initially division must go on
	      reset <= 0;
	      if(input_rdy) data_read <= 1;
	   end else begin
	      if(new_r) begin
		 if(div_ready) begin
		    quotient <= quotient_wire;
		    if(!quotient) begin
		       t <= new_t;
		       new_t <= t;
		       r <= new_r;
		       new_r <= r;
		       quotient_rdy_reg <= 1;
		    end else quotient_rdy_reg <= 0;
		 end
		 if(iteration_finished) begin
		    t <= new_t;
		    new_t <= t - t_wire;
		    r <= new_r;
		    new_r <= r - r_wire;
		    
		    reset <= 1;
		 end
//		 if(reset) reset <= 0;
		 
		 //		 new_r_empty <= 0;
	      end else begin // if (new_r)
		 if(r) begin
		    $display("not invertible");
		 end
		 if(t < 0) t <= t + modulus;
		 else begin
		    output_reg <= t;
		    out_valid <= 1;
		 end
		 
//		 new_r_empty <= 1;
	      end
	   end
	   
	end // else: !if(rst)
	if(reset) reset <= 0;
     end

endmodule // mod_exp
*/
	   
	   /*
	end else if(start_mod) begin // if (data_read == 0)
	   if(mod_finished) begin
	      reset <= 1;
	      start_mod <= 1;
	      new_t <= new_t_wire;
	   end
	end else begin
	   if(new_r) begin // if (data_read == 0)
	      if(!new_r[0]) begin
		 new_r <= new_r >> 2;
		 new_t <= new_t >> 2;
		 start_mod <= 1;
	      end
	      else begin
		 if(new_r < r) begin
		    new_r <= r;
		    new_t <= t;
		    r <= new_r;
		    t <= new_t;
		 end
		 new_r <= (new_r - r) >> 2;
		 new_t <= (new_t - t) >> 2;
		 start_mod <= 1;
	      end
	   end // if (new_r)
	   else begin
	      if(!(r == 1)) t <= 0;
	   end // else: !if(new_r)
	end // else: !if(start_mod)
	if(reset) reset <= 0;
     end // always @ (posedge clk)
endmodule   
	    */
   /*
   always @(posedge clk)
     begin
	if(rst) begin
	   modulus <= 0;
	   data_read <= 0;
	   reset <= 1;
	end
	if(data_read == 0) begin
	   new_r <= input_base_tdata;
	   r <= input_modulus_tdata;
	   t <= 0;
	   new_t <= 1;
	   modulus <= input_modulus_tdata;
	   
	   reset <= 0;
	   if(input_read) data_read <= 1;	
	end else if(start_mod) begin // if (data_read == 0)
	   if(mod_finished) begin
	      reset <= 1;
	      start_mod <= 1;
	      new_t <= new_t_wire;
	   end
	end else begin
	   if(new_r) begin // if (data_read == 0)
	      if(!new_r[0]) begin
		 new_r <= new_r >> 2;
		 new_t <= new_t >> 2;
		 start_mod <= 1;
	      end
	      else begin
		 if(new_r < r) begin
		    new_r <= r;
		    new_t <= t;
		    r <= new_r;
		    t <= new_t;
		 end
		 new_r <= (new_r - r) >> 2;
		 new_t <= (new_t - t) >> 2;
		 start_mod <= 1;
	      end
	   end // if (new_r)
	   else begin
	      if(!(r == 1)) t <= 0;
	   end // else: !if(new_r)
	end // else: !if(start_mod)
	if(reset) reset <= 0;
     end // always @ (posedge clk)
endmodule
    */
/*   
 always @(posedge clk)
 begin
 if(rst) begin
 modulus <= 0;
 data_read <= 0;
 reset <= 1;
 state <= 2'b00;
	end
 if(data_read == 0) begin
 new_r <= input_base_tdata;
 r <= input_modulus_tdata;
 t <= 0;
 new_t <= 1;
 modulus <= input_modulus_tdata;
 
 state <= 2'b00;
 reset <= 0;
 if(input_read) data_read <= 1;	
	   end else begin
 if(state == 2'b00) begin
 if(r < new_r) begin
 t <= new_t;
 new_t <= t;
 r <= new_r;
 new_r <= r;
 state <= 2'b01;
		 end else begin
 if(new_r == 0) begin
 state <= 2'b11;
		    end
		 end
	      end else if (state == 2'b01) begin
 if(div_ready) begin
 quotient <= quotient_wire;
 state <= 2'b10;
		 end
	      end else if (state == 2'b10) begin
 if(iteration_finished) begin
 t <= new_t;
 new_t <= t - t_wire;
 r <= new_r;
 new_r <= r - r_wire;
 
 reset <= 1;
 state <= 2'b00;
		 end
	      end else if (state == 2'b11) begin // if (state == 2'b10)
 if(r) t <= 0;
 if(t < 0) t <= t + modulus;
 out_valid <= 1;
	      end
	end
 if(reset) reset <= 0;
     end // if (data_read == 0)

 endmodule
 */
