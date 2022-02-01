//pseudo random number generateor based on Linear Feedback Shift Register

module LFSR (
	     input 	   clk,
	     input 	   rst,
	     input 	   input_tvalid,
	     input [63:0]  seed,
	     output 	   output_tvalid,
	     output [63:0] rnd 
	     );
   wire 		   feedback = random[63] ^ random[62] ^ random[60] ^ random[59]; 

   reg [63 : 0] 	   random, random_next, random_done;
   reg [5 : 0] 		   count, count_next; //to keep track of the shifts

   reg 			   data_read = 0;
   reg 			   out_valid;
      
   assign rnd = random_done;
   assign output_tvalid = out_valid;
   
   always @ (posedge clk)
     begin
	if (rst)
	  begin
	     //	     random <= 64'hFFFFFFFFFFFFFFFF;
	     random <= 0;
	     count <= 0;
	     out_valid <= 0;
	  end else begin
	     if(data_read == 0) begin
		out_valid <= 0;
		random <= seed;
		count <= 0;
		if(input_tvalid) data_read <= 1;
	     end else begin
		if(!input_tvalid) out_valid <= 0;
		random <= random_next;
		count <= count_next;
	     end
	  end
     end

   always @ (*)
     begin
	random_next = random;
	count_next = count;
	
	random_next = {random[62 : 0], feedback};
	count_next = count + 1;

	if (count == 63)
	  begin
	     count = 0;
	     random_done = random;
	     if(input_tvalid) out_valid = 1;
	  end
     end
endmodule
