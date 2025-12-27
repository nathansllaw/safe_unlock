module fsm_gates (
    input  logic clk,
    input  logic RESETN,
    input  logic ENTER,
    input  logic MATCH,
    output logic LOCKED,
    output logic savePW,
    output logic saveAT,
    output logic [2:0] present_state_bits
);

 
    logic [2:0] state, next_state;


    always_comb begin
        next_state = state;

        unique case (state)
            3'b000: if (ENTER)                 next_state = 3'b001; 
            3'b001: if (!ENTER)                next_state = 3'b101; 
            3'b101: if (!ENTER)                next_state = 3'b010; 
            3'b010: if (ENTER)                 next_state = 3'b011; 
            3'b011: if (!ENTER && MATCH)       next_state = 3'b100; 
                    else if (!ENTER && !MATCH) next_state = 3'b101;
            3'b100: if (!ENTER)                next_state = 3'b000; 
            default:                           next_state = 3'b000;
        endcase
    end


    always_comb begin
        LOCKED = 0;
        savePW = 0;
        saveAT = 0;

        case (state)
            3'b000: LOCKED = 0;                  
            3'b001: begin savePW = 1; LOCKED = 0; end
            3'b010: LOCKED = 1;                    
            3'b011: begin saveAT = 1; LOCKED = 1; end
            3'b100: LOCKED = 0;                     
            3'b101: LOCKED = 1;                     
            default: LOCKED = 0;
        endcase
    end


    always_ff @(posedge clk or negedge RESETN) begin
        if (!RESETN)
            state <= 3'b000;
        else
            state <= next_state;
    end

    assign present_state_bits = state;

endmodule
