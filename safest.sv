module safest(
			input logic MAX10_CLK1_50,
			input logic [9:0] SW,
			input logic [1:0] KEY,
			output logic [9:0] LEDR,
			output logic [7:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);

		logic savePW, saveAT, MATCH, LOCKED;
		logic [2:0] present_state_bits;
		
		localparam logic [47:0] HEX_OPEN = 48'hFC_C0_8C_86_AB_F7;
		localparam logic [47:0] HEX_LOCKED = 48'hC7_C0_C6_89_86_C0;
		logic [47:0] HEX_DISPLAY;
		
		fsm_safest FSM (
				.clk (MAX10_CLK1_50),
				.RESETN (KEY[0]),
				.ENTER  (~KEY[1]),
				.MATCH  (MATCH),
				.LOCKED (LOCKED),
				.savePW (savePW),
				.saveAT (saveAT),
				.present_state_bits (present_state_bits)
		);
		
		logic [9:0] ATTEMPT, PASSWORD;
		
		always_ff @(posedge MAX10_CLK1_50)
			begin
				
				if (~KEY[0]) begin
					ATTEMPT = 10'b1111111111;
					PASSWORD = 10'b0000000000;
				end
				
				else begin
				
					if(savePW) PASSWORD <= SW;
					
					if(saveAT) ATTEMPT <= SW;
				end
			end
			
			assign MATCH = (ATTEMPT == PASSWORD);
			
			logic [9:0] difference;
			logic [3:0] HINT;
			
			assign difference = SW ^ PASSWORD;
			
			always_comb begin
				HINT = 0;
				
				for(int i = 0; i < 10; i++)
					HINT += difference[i];
			end
			
			
			always_comb begin
			
				if (LOCKED) HEX_DISPLAY = HEX_LOCKED;
				
				else HEX_DISPLAY = HEX_OPEN;
				
				LEDR = 10'b0;
				LEDR[3:0] = HINT;
				LEDR[9:4] = {3'b000, present_state_bits};
			end
			
			assign {HEX5,HEX4,HEX3,HEX2,HEX1,HEX0} = HEX_DISPLAY;
			
endmodule
			
				