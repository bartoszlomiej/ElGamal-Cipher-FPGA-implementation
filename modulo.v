`timescale 1ns / 1ps

module modulo #(parameter SIZE = 128)
   (
    input wire 		     clk, rst,
    // using AXI stream inputs
    wire [SIZE-1 : 0] 	     input_dividen_tdata,
    input wire 		     input_dividen_tvalid,
    output wire 	     input_dividen_tready,
   
    input wire [SIZE-1 : 0]  input_divisor_tdata,
    input wire 		     input_divisor_tvalid, 
    output wire 	     input_divisor_tready,
    // using AXI stream outputs
    output wire [SIZE-1 : 0] output_tdata,
    output wire 	     output_tvalid, 
    input wire 		     output_tready
    );
   
   reg [SIZE-1 : 0] 	     dividen;
   reg [SIZE-1 : 0] 	     divisor;

   reg [SIZE-1 : 0] 	     reminder;
   reg 			     out_valid;
   
   reg [SIZE-1 : 0] 	     new_divisor;
   reg [SIZE-1 : 0] 	     prev_divisor;
   reg [1:0] 		     state = 0;

   wire 		     input_rdy = input_dividen_tvalid & input_divisor_tvalid;

   assign output_tdata = reminder;
   
   
   always @(posedge clk)
     begin
	if(rst) begin
	   dividen <= 0;

	   divisor <= 0;

	   reminder <= 0;
	   out_valid <= 0;
	end else begin
	   if(state == 2'b00) begin
	      if(input_rdy) begin
		 dividen <= input_dividen_tdata;
		 divisor <= input_divisor_tdata;
	      
		 prev_divisor <= input_divisor_tdata;
		 new_divisor <= input_divisor_tdata;
	      
		 state <= 2'b01;
	      end
	   end
	   else if(state == 2'b01) begin
	      if(new_divisor < dividen) begin
		 prev_divisor <= new_divisor;	      
		 new_divisor <= prev_divisor << 1;

		 state <= 2'b10;
	      end
	   end else if(state == 2'b10) begin
	      dividen = dividen - prev_divisor;
	      
	      state <= 2'b11;
	   end else if(state == 2'b11) begin
	      if(dividen > divisor) begin
		 dividen = dividen - divisor;
	      end else begin
		 reminder = dividen;
		 out_valid <= 1;
	      end
	   end
	end
     end

endmodule
