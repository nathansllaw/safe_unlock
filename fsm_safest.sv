module fsm_safest(
			input 	logic clk,
			input 	logic RESETN,
			input 	logic ENTER,
			input 	logic MATCH,
			output 	logic LOCKED,
			output 	logic savePW,
			output 	logic saveAT,
			output 	logic [1:0] present_state_bits
);

	typedef enum logic [1:0]{
			S0_OPEN			= 2'b00,
			S1_OPEN_WAIT 	= 2'b10,
			S2_LOCKED 		= 2'b01,
			S3_LOCKED_WAIT = 2'b11
		} state_t;
		
		state_t present_state, next_state;
		
		always_comb begin
		
			LOCKED = 1'b0;
			savePW = 1'b0;
			saveAT = 1'b0;
			
			case (present_state)
				S0_OPEN: begin
					LOCKED = 1'b0;
					savePW = 1'b0;
					saveAT = 1'b0;
				end
				
				S1_OPEN_WAIT: begin
					LOCKED = 1'b0;
					savePW = 1'b1;
					saveAT = 1'b0;
				end
				
				S2_LOCKED: begin
					LOCKED = 1'b1;
					savePW = 1'b0;
					saveAT = 1'b0;
				end
				
				S3_LOCKED_WAIT: begin
					LOCKED = 1'b1;
					savePW = 1'b0;
					saveAT = 1'b1;
				end
			endcase
		end
		
		always_comb begin
			
			next_state = present_state;
			
			case(present_state)
				S0_OPEN: if (ENTER) next_state = S1_OPEN_WAIT;
				
				S1_OPEN_WAIT: if (!ENTER) next_state = S2_LOCKED;
				
				S2_LOCKED: if (ENTER) next_state = S3_LOCKED_WAIT;
				
				S3_LOCKED_WAIT: begin
					
					if (!ENTER && MATCH) next_state = S0_OPEN;
					
					else if (!ENTER && !MATCH) next_state = S2_LOCKED;
					
				end
			endcase
		end
		
		always_ff @(posedge clk) begin
			if ( ~RESETN )
				present_state = S0_OPEN;
			
			else
				present_state = next_state;
		end
		
		assign present_state_bits = present_state;
		
endmodule