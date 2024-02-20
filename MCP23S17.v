module MCP23S17
(
	input clk,
	input cs,
	input mosi,
	input reset,
	input [2:0] address,
	
	output reg miso,
	output reg inta,
	output reg intb,
	
	inout reg[7:0] porta,
	inout reg[7:0] portb
);

localparam DEFAULT_IODIRx = 8'b11111111;
localparam DEFAULT_IPOLx = 8'b00000000;
localparam DEFAULT_GPINTENx = 8'b00000000;
localparam DEFAULT_DEFVALx = 8'b00000000;
localparam DEFAULT_INTCONx = 8'b00000000;
localparam DEFAULT_IOCONx = 8'b00000000;
localparam DEFAULT_GPPUx = 8'b00000000;
localparam DEFAULT_INTFx = 8'b00000000;
localparam DEFAULT_INTCAPx = 8'b00000000;
localparam DEFAULT_GPIOx = 8'b00000000;
localparam DEFAULT_OLATx = 8'b00000000;

localparam STATE_OPCODE = 0;
localparam STATE_ADDRESS = 1;
localparam STATE_DATA = 2;

localparam NUM_REGISTERS = 22;

reg[7:0] regfile [NUM_REGISTERS];
reg[7:0] workingAddress = 0;
reg[2:0] state = STATE_OPCODE;
reg[4:0] bitcounter = 0;
reg read;

regfile[0] = regfile[1] = DEFAULT_IODIRx;
regfile[2] = regfile[3] = DEFAULT_IPOLx;
regfile[4] = regfile[5] = DEFAULT_GPINTENx;
regfile[6] = regfile[7] = DEFAULT_DEFVALx;
regfile[8] = regfile[9] = DEFAULT_INTCONx;
regfile[10] = regfile[11] = DEFAULT_IOCONx;
regfile[12] = regfile[13] = DEFAULT_GPPUx;
regfile[14] = regfile[15] = DEFAULT_INTFx;
regfile[16] = regfile[17] = DEFAULT_INTCAPx;
regfile[18] = regfile[19] = DEFAULT_GPIOx;
regfile[20] = regfile[21] = DEFAULT_OLATx;

always @(posedge clk) begin
	if(cs == 1) begin
		case(state)
			STATE_OPCODE: begin
			workingAddress <= {workingAddress[6:0], mosi};
			if(bitcounter < 7) begin
				bitcounter <= bitcounter + 1;
			end else begin
				if(workingAddress[7:4] == 4'b0100) begin
					if(!regfile[5][3] || workingAddress[3:1] == address) begin
						state <= STATE_ADDRESS;
						read <= workingAddress[0];
					end
				end
				workingAddress <= 0;
				bitcounter <= 0;
			end
			end
			
			STATE_ADDRESS: begin
			workingAddress <= {workingAddress[6:0], mosi};
			if(bitcounter < 7) begin
				bitcounter <= bitcounter + 1;
			end else begin
				state <= STATE_DATA;
				bitcounter <= 0;
			end
			end
			
			STATE_DATA: begin
			if(workingAddress < NUM_REGISTERS) begin
				miso <= regfile[workingAddress][~bitcounter];
				if(workingAddress < 7) begin
					workingAddress <= workingAddress + 1;
				end else begin
					if(workingAddress < (NUM_REGISTERS - 1))
						workingAddress <= workingAddress + 1;
					else
						workingAddress <= 0;
				end
			end else begin
				miso <= 0;
			end
			end
		endcase
	end
	
	
end

always @(posedge cs) begin
	state <= STATE_OPCODE;
	bitcounter <= 0;
end

always @(negedge reset) begin
	regfile[0] = regfile[1] = DEFAULT_IODIRx;
	regfile[2] = regfile[3] = DEFAULT_IPOLx;
	regfile[4] = regfile[5] = DEFAULT_GPINTENx;
	regfile[6] = regfile[7] = DEFAULT_DEFVALx;
	regfile[8] = regfile[9] = DEFAULT_INTCONx;
	regfile[10] = regfile[11] = DEFAULT_IOCONx;
	regfile[12] = regfile[13] = DEFAULT_GPPUx;
	regfile[14] = regfile[15] = DEFAULT_INTFx;
	regfile[16] = regfile[17] = DEFAULT_INTCAPx;
	regfile[18] = regfile[19] = DEFAULT_GPIOx;
	regfile[20] = regfile[21] = DEFAULT_OLATx;
	
	state <= STATE_OPCODE;
	bitcounter <= 0;
end

endmodule