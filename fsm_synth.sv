module fsm_synth (
    input  logic clk,
    input  logic RESETN,
    input  logic ENTER,
    input  logic MATCH,
    output logic LOCKED,
    output logic savePW,
    output logic saveAT,
    output logic [2:0] present_state_bits
);

    typedef enum logic [2:0] {
        S0_OPEN              = 3'b000,
        S1_SAVE_PW           = 3'b001,
        S2_LOCKED            = 3'b010,
        S3_SAVE_AT           = 3'b011,
        S4_OPEN_WAIT_RELEASE = 3'b100,
        S5_LOCKED_WAIT_REL   = 3'b101
    } state_t;

    state_t present_state, next_state;

    always_comb begin
        LOCKED = 1'b0;
        savePW = 1'b0;
        saveAT = 1'b0;
		  
        case (present_state)
            S0_OPEN:              LOCKED = 1'b0;
				
            S1_SAVE_PW:  
				 begin 
				  
				  savePW = 1'b1; 
				  LOCKED = 1'b0; 
				  
				 end
				 
            S2_LOCKED:            LOCKED = 1'b1;
				
            S3_SAVE_AT:  
				 begin 
				  
				  saveAT = 1'b1; 
				  LOCKED = 1'b1;
				  
				 end
            
				S4_OPEN_WAIT_RELEASE: LOCKED = 1'b0;
           
			   S5_LOCKED_WAIT_REL:   LOCKED = 1'b1;
            
				default:              LOCKED = 1'b0;
        endcase
    end

    always_comb begin
        next_state = present_state;
        unique case (present_state)
            S0_OPEN: if (ENTER) next_state = S1_SAVE_PW;
				
            S1_SAVE_PW: if (!ENTER) next_state = S5_LOCKED_WAIT_REL;
				
            S5_LOCKED_WAIT_REL: if (!ENTER) next_state = S2_LOCKED;
				
            S2_LOCKED: if (ENTER) next_state = S3_SAVE_AT;
				
            S3_SAVE_AT: 
				 begin
				 
				  if (!ENTER && MATCH) next_state = S4_OPEN_WAIT_RELEASE;
				  else if (!ENTER && !MATCH) next_state = S5_LOCKED_WAIT_REL;
				 end
				 
            S4_OPEN_WAIT_RELEASE: if (!ENTER) next_state = S0_OPEN;
        endcase
    end

    always_ff @(posedge clk) begin
        if (!RESETN)
            present_state <= S0_OPEN;
        else
            present_state <= next_state;
    end

    assign present_state_bits = present_state;

endmodule
