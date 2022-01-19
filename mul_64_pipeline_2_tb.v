module mult_64_pipeline_2_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [31:0] input_a_tdata;
	reg [31:0] input_b_tdata;
	reg input_a_tvalid;
	reg input_b_tvalid;
	reg output_tready;

	// Outputs
	wire input_a_tready;
	wire input_b_tready;
	wire [63:0] output_tdata;
	wire output_tvalid;

	// Instantiate the Unit Under Test (UUT)
	mult_64_pipeline_2 uut (
		.clk(clk), 
		.rst(rst), 
		.input_a_tdata(input_a_tdata), 
		.input_b_tdata(input_b_tdata), 
		.input_a_tvalid(input_a_tvalid), 
		.input_b_tvalid(input_b_tvalid), 
		.input_a_tready(input_a_tready), 
		.input_b_tready(input_b_tready), 
		.output_tdata(output_tdata), 
		.output_tvalid(output_tvalid), 
		.output_tready(output_tready)
	);
	initial begin
		clk = 0;
		forever begin
			#10 clk = ~clk;
		end
	end
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		input_a_tdata = 32'd13321234;
		input_b_tdata = 32'd54412351;
		#5;
		input_a_tvalid = 1;
		input_b_tvalid = 1;
		#12;
		output_tready = 1;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

