//unsigned multiplication of two 16 bit numbers
module mult_32 #(parameter SIZE = 32)(
		input [15:0]  multiplier, multiplicand, 
		input 	      clk,
		input 	      start, 
		output wire ready,
		output wire [31:0] res
		);
		
	reg [SIZE-1 : 0] res_reg;
	reg ready_reg;
	reg [(SIZE/2)-1 : 0] multiplier_reg;
	reg [(SIZE/2)-1 : 0] multiplicand_reg;
	
	assign res = res_reg;
	assign ready = ready_reg;
	
   always @(posedge clk)
		begin
			res_reg <= multiplier * multiplicand;
			ready_reg <= 1'b1;
		end
endmodule

//unsigned multiplication of two 16 bit numbers
module mult_32 #(parameter SIZE = 32)(
		input wire 	   clk, rst,
				      /* using AXI stream inputs */				      
		input wire [(SIZE/2)-1:0]  input_a_tdata,
		input wire 	   input_a_tvalid,
		output wire 	   input_a_tready,
				      
		input wire [(SIZE/2)-1:0]  input_b_tdata,
		input wire 	   input_b_tvalid, 
		output wire 	   input_b_tready,
				      /* using AXI stream outputs */
		output wire [SIZE-1:0] output_tdata,
		output wire 	   output_tvalid,				      				      
		input wire 	   output_tready
		);
   
   reg [SIZE-1 : 0] 		   output_tdata_reg0 = 0;
   reg [SIZE-1 : 0] 		   output_tdata_reg1 = 0;
   
   reg [(SIZE/2)-1 : 0] 	   input_a_reg0 = 0;
   reg [(SIZE/2)-1 : 0] 	   input_a_reg1 = 0;

   reg [(SIZE/2)-1 : 0] 	   input_b_reg0 = 0;
   reg [(SIZE/2)-1 : 0] 	   input_b_reg1 = 0;

   wire 			   transfer = input_a_tvalid & input_b_tvalid & output_tready;
   

   assign input_a_tready = input_b_tvalid & output_tready;
   assign input_b_tready = input_a_tvalid & output_tready;

   assign output_tdata = output_tdata_reg1;
   assign output_tvalid = input_a_tvalid & input_b_tvalid;
   
   always @(posedge clk)
     begin
	if(res) begin
	   input_a_reg0 <= 0;
	   input_a_reg1 <= 0;

	   input_b_reg0 <= 0;
	   input_b_reg1 <= 0;

	   output_reg0 <= 0;
	   output_reg1 <= 0;	   
	end else begin
	   if(transfer) begin
	      input_a_reg0 <= input_a_tdata;
	      input_b_reg0 <= input_b_tdata;

	      input_a_reg1 <= input_a_reg0;
	      input_b_reg1 <= input_b_reg0;

	      output_reg0 <= input_a_reg0 * input_b_reg0;

	      output_reg1 <= output_reg0;
	   end
	end // else: !if(res)
     end // always @ (posedge clk)
endmodule
/*
 `timescale 1ns / 1ps


//unsigned multiplication of two SIZE/2 bit numbers
module mult_32_pipeline_2 #(parameter SIZE = 32)(
		input wire 	   clk, rst,
				      // using AXI stream inputs
  wire [(SIZE/2)-1:0]  input_a_tdata,
		input wire 	   input_a_tvalid,
		output wire 	   input_a_tready,
				      
		input wire [(SIZE/2)-1:0]  input_b_tdata,
		input wire 	   input_b_tvalid, 
		output wire 	   input_b_tready,
				      // using AXI stream outputs
		output wire [SIZE-1:0] output_tdata,
		output wire 	   output_tvalid,				      				      
		input wire 	   output_tready
		);
   
   reg [SIZE-1 : 0] 		   output_reg0 = 0;
   reg [SIZE-1 : 0] 		   output_reg1 = 0;
   
   reg [(SIZE/2)-1 : 0] 	   input_a_reg0 = 0;
   reg [(SIZE/2)-1 : 0] 	   input_a_reg1 = 0;

   reg [(SIZE/2)-1 : 0] 	   input_b_reg0 = 0;
   reg [(SIZE/2)-1 : 0] 	   input_b_reg1 = 0;

   wire 			   transfer = input_a_tvalid & input_b_tvalid & output_tready;
   

   assign input_a_tready = input_b_tvalid & output_tready;
   assign input_b_tready = input_a_tvalid & output_tready;

   assign output_tdata = output_reg1;
   assign output_tvalid = input_a_tvalid & input_b_tvalid;
   
   always @(posedge clk)
     begin
	if(rst) begin
	   input_a_reg0 <= 0;
	   input_a_reg1 <= 0;

	   input_b_reg0 <= 0;
	   input_b_reg1 <= 0;

	   output_reg0 <= 0;
	   output_reg1 <= 0;	   
	end else begin
	   if(transfer) begin
	      input_a_reg0 <= input_a_tdata;
	      input_b_reg0 <= input_b_tdata;

	      input_a_reg1 <= input_a_reg0;
	      input_b_reg1 <= input_b_reg0;

	      output_reg0 <= input_a_reg1 * input_b_reg1;

	      output_reg1 <= output_reg0;
	   end
	end
	end
endmodule
*/
