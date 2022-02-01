`timescale 1ns / 1ps

module decrypting_entity #(parameter SIZE = 64)
   (
    input wire 		     clk, rst,
    // using AXI stream inputs
    wire [SIZE-1 : 0] 	     input_first_tdata,
    input wire 		     input_first_tvalid,
    output wire 	     input_first_tready,
   
    input wire [SIZE-1 : 0]  input_second_tdata,
    input wire 		     input_second_tvalid, 
    output wire 	     input_second_tready,
    // using AXI stream outputs
    output wire [SIZE-1 : 0] output_a_tdata,
    output wire 	     output_a_tvalid, 
    input wire 		     output_a_tready,
    
    output wire [SIZE-1 : 0] output_b_tdata,
    output wire 	     output_b_tvalid, 
    input wire 		     output_b_tready,

    output wire [SIZE-1 : 0] output_c_tdata,
    output wire 	     output_c_tvalid, 
    input wire 		     output_c_tready
    );
   
   reg [SIZE-1 : 0] 	     first;
   reg [SIZE-1 : 0] 	     second;

   reg [SIZE-1 : 0] 	     private_key;
   wire [SIZE-1 : 0] 	     private_key_wire;
   wire 		     private_key_ready;
   
   reg [SIZE-1 : 0] 	     public_key;
   wire [SIZE-1 : 0] 	     public_key_wire;
   wire 		     public_key_ready;

   reg [SIZE-1 : 0] 	     output_a_reg;
   reg [SIZE-1 : 0] 	     output_b_reg;
   reg [SIZE-1 : 0] 	     output_c_reg;
   
   reg 			     out_a_valid, out_b_valid, out_c_valid;
   reg 			     state = 0;


   reg 			     generate_private_key = 0;
   wire 		     seed_ready = generate_private_key;

   reg 			     generate_public_key = 0;
   wire 		     run_public_key = generate_public_key;
       
   reg 			     data_read = 0;
   wire 		     input_read;
   wire 		     input_rdy = input_first_tvalid & input_second_tvalid;

   reg 			     reset;
   
   assign input_read = data_read;
   assign output_tvalid = out_a_valid & out_b_valid & out_c_valid;
   assign output_a_tdata = output_a_reg;
   assign output_b_tdata = output_b_reg;
   assign output_c_tdata = output_c_reg;

   assign rst_rng = reset;
   assign rst_mod_exp = reset;

   LFSR private_key_generator (
			       .clk(clk), 
			       .rst(rst_rng),
			       .input_tvalid(seed_ready),
			       .seed(first),
			       .output_tvalid(private_key_ready),
			       .rnd(private_key_wire)
			       );
   
   mod_exp public_key_generator(
				.clk(clk), 
				.rst(rst_mod_exp), 
				.input_base_tdata(second),
				.input_base_tvalid(input_read), 
//				.input_base_tready(base_tready), 
				.input_power_tdata(private_key), 
				.input_power_tvalid(run_public_key), 
//				.input_power_tready(power_tready),
				.input_modulus_tdata(first), 
				.input_modulus_tvalid(input_read), 
//				.input_modulus_tready(modulus_tready), 
				.output_tdata(public_key_wire), 
				.output_tvalid(public_key_ready), 
				.output_tready(input_read)
				);
   always @(posedge clk)
     begin
	if(rst) begin
	   first <= 0;
	   second <= 0;
	   state <= 0;
	   out_a_valid <= 0;
	   out_b_valid <= 0;
	   out_c_valid <= 0;
	end else begin
	   if(!state) begin
	      //part 1 - private and public key establishing
	      if(!input_read) begin
		 first <= input_first_tdata;
		 second <= input_second_tdata;
		 if(input_rdy) begin 
		    data_read <= 1;
		    generate_private_key <= 1;
		 end
	      end else begin
		 if(private_key_ready) begin
		    private_key <= private_key_wire;
		    generate_private_key <= 0;
		    if(private_key < (first + 1)) begin
		       generate_public_key <= 1;
		       //now let public key be generated
		    end
		 end
		 if(public_key_ready) begin
		    generate_public_key <= 0;
		    output_a_reg <= first; // the prime p of the multiplicative group Z*_p
		    output_b_reg <= second; //the generator of the group
		    output_c_reg <= public_key_wire; //public key
		    public_key <= public_key_wire;
		    state <= 1;
		    reset <= 1;
		 end
	      end
	   end else begin // if (!state)
	      
	      //part 2 - decryption
	   end
	end // else: !if(rst)
	if(reset) reset <= 0;
	
     end // always @ (posedge clk)
endmodule

