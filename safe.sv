module safe (
	 input  logic [9:0] SW,          
    input  logic [1:0] KEY,         
    input  logic       MAX10_CLK1_50, 
    output logic [9:0] LEDR,        
    output logic [7:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);


	logic savePW, saveAT, LOCKED;
	logic [2:0] present_state_bits;
	logic MATCH;

		 fsm_gates FSM (
			  .clk      (MAX10_CLK1_50),
			  .RESETN   (KEY[0]),
			  .ENTER    (~KEY[1]),
			  .MATCH    (MATCH),
			  .LOCKED   (LOCKED),
			  .savePW   (savePW),
			  .saveAT   (saveAT)
		 );

	 
	 
    logic [9:0] PASSWORD, ATTEMPT; 
    
	 always_ff @(posedge MAX10_CLK1_50) begin
        if (~KEY[0]) begin            
            PASSWORD <= 10'b0000000000; 
            ATTEMPT  <= 10'b1111111111; 
        end
        else begin
            if (savePW)
                PASSWORD <= SW;      
            if (saveAT)
                ATTEMPT <= SW;        
        end
    end
	 
    assign MATCH = (ATTEMPT == PASSWORD);

    
    logic [9:0] diff;
    logic [3:0] HINT;
    assign diff = SW ^ PASSWORD;

    always_comb begin
        HINT = 0;
        for (int i = 0; i < 10; i++)
            HINT += diff[i];
    end

   
    localparam logic [47:0] OPEN_PATTERN   = 48'hFC_C0_8C_86_AB_F7; 
    localparam logic [47:0] LOCKED_PATTERN = 48'hC7_C0_C6_89_86_C0;
    logic [47:0] HEX_DISPLAY;

    always_comb begin
        if (LOCKED)
            HEX_DISPLAY = LOCKED_PATTERN;
        else
            HEX_DISPLAY = OPEN_PATTERN;

        LEDR = 10'b0;
        LEDR[3:0] = HINT; 
		  LEDR[9:4] = {3'b000, present_state_bits};
    end

    
    assign {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0} = HEX_DISPLAY;
endmodule
