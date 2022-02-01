`timescale 1ns / 1ps

module encrypting_entity #(parameter SIZE = 64)
   (
    input wire 		     clk, rst,
    // using AXI stream inputs
    wire [SIZE-1 : 0] 	     input_p_tdata,
    input wire 		     input_p_tvalid,
    output wire 	     input_p_tready,
/*   
    input wire [SIZE-1 : 0]  input_alpha_tdata,
    input wire 		     input_alpha_tvalid, 
    output wire 	     input_alpha_tready,
*/
    input wire [SIZE-1 : 0]  input_a_key_tdata,
    input wire 		     input_a_key_tvalid, 
    output wire 	     input_a_key_tready, 

    input wire [SIZE-1 : 0]  input_m_tdata,
    input wire 		     input_m_tvalid, 
    output wire 	     input_m_tready, 
    // using AXI stream outputs
    output wire [SIZE-1 : 0] output_a_tdata,
    output wire 	     output_a_tvalid, 
    input wire 		     output_a_tready,
   
    output wire [SIZE-1 : 0] output_b_tdata,
    output wire 	     output_b_tvalid, 
    input wire 		     output_b_tready
    );
   
   reg [SIZE-1 : 0] 	     p;
//   reg [SIZE-1 : 0] 	     alpha;
   reg [SIZE-1 : 0] 	     a_key; //decrypting_entity key

   reg [SIZE-1 : 0] 	     m; //message

   reg [SIZE-1 : 0] 	     private_key;
   wire [SIZE-1 : 0] 	     private_key_wire;
   wire 		     private_key_ready;
   
   reg [SIZE-1 : 0] 	     public_key;
   wire [SIZE-1 : 0] 	     public_key_wire;
   wire 		     public_key_ready;

   reg [SIZE-1 : 0] 	     cryptogram;
   wire [SIZE-1 : 0] 	     cryptogram_wire;
   wire 		     cryptogram_ready;
   
   reg 			     out_a_valid, out_b_valid;
   reg 			     state = 0;


   reg 			     generate_private_key = 0;
   wire 		     seed_ready = generate_private_key;

   reg 			     generate_public_key = 0;
   wire 		     run_public_key = generate_public_key;
   wire 		     run_encryption = state;
   
   reg 			     data_read = 0;
   wire 		     input_read;
   wire 		     input_rdy = input_p_tvalid & input_a_key_tvalid & input_m_tvalid;

   reg 			     reset = 0;
   wire 		     finish;

   wire 		     rst_mult, rst_rng, rst_mod_exp;
   reg 			     out_valid;
   
   assign input_read = data_read;
   assign output_tvalid = out_a_valid & out_b_valid;
   assign output_a_tdata = public_key;
   assign output_b_tdata = cryptogram;

   assign rst_rng = reset;
   assign rst_mod_exp = reset;
   assign rst_mult = reset;
   
   assign output_a_tvalid = out_valid;
   assign output_b_tvalid = out_valid;
   
   
   LFSR private_key_generator (
			       .clk(clk), 
			       .rst(rst_rng),
			       .input_tvalid(seed_ready),
			       .seed(a_key), //just to present different seed than entity A
			       .output_tvalid(private_key_ready),
			       .rnd(private_key_wire)
			       );
   
   mod_exp public_key_generator(
				.clk(clk), 
				.rst(rst_mod_exp), 
				.input_base_tdata(a_key),
				.input_base_tvalid(input_read), 
				//				.input_base_tready(base_tready), 
				.input_power_tdata(private_key), 
				.input_power_tvalid(run_public_key), 
				//				.input_power_tready(power_tready),
				.input_modulus_tdata(p), 
				.input_modulus_tvalid(input_read), 
				//				.input_modulus_tready(modulus_tready), 
				.output_tdata(public_key_wire), 
				.output_tvalid(public_key_ready), 
				.output_tready(input_read)
				);

   multiplication_modulo encrypt(
				 .clk(clk), 
				 .rst(rst_mult), 
				 .input_multiplier_tdata(m), 
				 .input_multiplier_tvalid(run_encryption),
				 .input_multiplicand_tdata(public_key), 
				 .input_multiplicand_tvalid(run_encryption), 
				 .input_modulus_tdata(p), 
				 .input_modulus_tvalid(run_encryption), 
				 .output_tdata(cryptogram_wire), 
				 .output_tvalid(finish), 
				 .output_tready(run_encryption)
				 );   

   always @(posedge clk)
     begin
	if(rst) begin
	   p <= 0;
//	   alpha <= 0;
	   state <= 0;
	   public_key <= 0;
	   cryptogram <= 0;
	   m <= 0;
	   a_key <= 0;
	   out_valid <= 0;
	end else begin
	   if(!state) begin
	      //part 1 - private and public key establishing
	      if(!input_read) begin
		 p <= input_p_tdata;
//		 alpha <= input_alpha_tdata;
		 m <= input_m_tdata;
		 a_key <= input_a_key_tdata;
		 if(input_rdy) begin 
		    data_read <= 1;
		    generate_private_key <= 1;
		 end
	      end else begin
		 if(private_key_ready) begin
		    private_key <= private_key_wire;
		    generate_private_key <= 0;
		    if(private_key < (p + 1)) begin
		       generate_public_key <= 1;
		       //now let public key be generated
		    end
		 end
		 if(public_key_ready) begin
		    generate_public_key <= 0;
		    public_key <= public_key_wire;
		    state <= 1;
		 end
	      end
	   end else begin // if (!state)
	      //part 2 - encryption of the message
	      if(finish) begin
		 cryptogram <= cryptogram_wire;
		 out_valid <= 1;
		 reset <= 1;
	      end
	   end
	end // else: !if(rst)
	if(reset) reset <= 0;
	
     end // always @ (posedge clk)
endmodule

