module mult_34 (
		input wire 	   clk, rst,
				      // using AXI stream inputs
		wire [16:0] 	   input_a_tdata,
		input wire 	   input_a_tvalid,
		output wire 	   input_a_tready,
				      
		input wire [16:0]  input_b_tdata,
		input wire 	   input_b_tvalid, 
		output wire 	   input_b_tready,
				      // using AXI stream outputs
		output wire [33:0] output_tdata,
		output wire 	   output_tvalid, 
		input wire 	   output_tready
		);
   
   reg [33 : 0] 		   output_reg0 = 0;
   reg [33 : 0] 		   output_reg1 = 0;
   
   reg [16 : 0] 	   input_a_reg0 = 0;
   reg [16 : 0] 	   input_a_reg1 = 0;

   reg [16 : 0] 	   input_b_reg0 = 0;
   reg [16 : 0] 	   input_b_reg1 = 0;

   reg [2:0] 		   out_valid = 0;
   
   wire 		   transfer = input_a_tvalid & input_b_tvalid & output_tready;
   

   assign input_a_tready = input_b_tvalid & output_tready;
   assign input_b_tready = input_a_tvalid & output_tready;

   assign output_tdata = output_reg1;
   assign output_tvalid = out_valid[2];
   
//   assign output_tvalid = input_a_tvalid & input_b_tvalid;
   
   always @(posedge clk)
     begin
	if(rst) begin
	   input_a_reg0 <= 0;
	   input_a_reg1 <= 0;

	   input_b_reg0 <= 0;
	   input_b_reg1 <= 0;

	   output_reg0 <= 0;
	   output_reg1 <= 0;
	   out_valid <= 0;
	end else begin
	   if(transfer) begin
	      input_a_reg0 <= input_a_tdata;
	      input_b_reg0 <= input_b_tdata;

	      input_a_reg1 <= input_a_reg0;
	      input_b_reg1 <= input_b_reg0;

	      output_reg0 <= input_a_reg1 * input_b_reg1;

	      output_reg1 <= output_reg0;

	      if(out_valid < 3'b100) begin	      
		 out_valid <= out_valid + 1'b1;
	      end
	      
	   end
	end
	end
endmodule
