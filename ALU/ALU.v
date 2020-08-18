// Sergio Jimenez
// ALU module for RISC processor
// initial work for multiplication matrix engine, only mult tested but everything is in there
// Single, 256 bit tristated bus
// 5 bits control the actions to be taken in the ALU, additional enable bit that performs selected action
// 3 bit OPCODE, not all range performs and action
// 2 bit ALTERATION, alters the instruction to be performed
// 
// Note on Scalar Multiply
// 3 bit scale_bits serves the purpose of feeding in the nescessary bits to perform the identity matrix generation.
// considered part of the instruction, but is the same bus as the memory address. Memory is not called during this instruction,
// 
// 
// Supported OPCODES
// 001 LOAD        ---------------------------------------------------- | --------------------------------------------------------
//				   00 C Register to A Register 		 3 bit source		| Internal movement from result to A register
//				   01 Write to A Register			 3 bit source		| Write into A register from bus
//				   10 Write to B Register			 3 bit source		| Write into B register from bus
//				   11 C Register to dataBus			 3 bit destination	| Dump whatever is in C register to bus
//																		|
// 010 ADD  	   ---------------------------------------------------- | --------------------------------------------------------
//				   00 C Register to A Register   	 3 bit destination  | Internal movement from result to A register
//				   11 C Register to dataBus								| Dump whatever is in C register to bus
//																		|
// 011 SUB   	   ---------------------------------------------------- | --------------------------------------------------------
//				   00 C Register to A Register       3 bit destination  | Internal movement from result to A register
//				   11 C Register to dataBus								| Dump whatever is in C register to bus
//																		|
// 100 SCAL MUL    ---------------------------------------------------- | --------------------------------------------------------
//				   5 bits determine scale factor 						| generates identity matrix to perform scalar multiply
//				   XXXXXX 0 - 31										| will automatically place identity matrix in B register 
//																		| and perform the operation, send to C register
//																		|
// 101 MATR MUL    ---------------------------------------------------- | --------------------------------------------------------
//				   00 C Register to A Register		 3 bit destination  | Internal movement from result to A register
//				   11 C Register to dataBus								| Dump whatever is in C register to bus
//																		|
// 110 TRANSPOSE   ---------------------------------------------------- | --------------------------------------------------------
//				   00 C Register to A Register		 3 bit destination  | Internal movement from result to A register
//				   11 C Register to dataBus								| Dump whatever is in C register to bus

`timescale 1ns/1ns
module ALU (dataBus, scale_bits, op_code, ALU_ALT, nALU_Enable, clk, reset);

// control inputs
input wire [2:0] op_code, scale_bits;  // scale bits same ass mem address bus. will be used for additional scaling function
input wire [1:0] ALU_ALT;
input wire reset, clk, nALU_Enable;

// 256 bit databus
inout [255:0] dataBus;

reg outEnable;
reg [15:0]  scalefactor;
reg [15:0] MemArray   [3:0][3:0]; // unpack
reg [15:0] A_register [3:0][3:0]; // A input register
reg [15:0] B_register [3:0][3:0]; // B input register
reg [15:0] C_register [3:0][3:0]; // C result register
reg [255:0] outArray; // repack

parameter NO_OP     = 3'b 000;
parameter LOAD      = 3'b 001;
parameter ADD       = 3'b 010;
parameter SUB       = 3'b 011;
parameter SCAL_MUL  = 3'b 100;
parameter MATR_MUL  = 3'b 101;
parameter TRANSPOSE = 3'b 110;
parameter START     = 3'b 111;

// 
parameter WRITE_A   = 2'b 01; // from bus to A register. used only in LOAD instruction
parameter WRITE_B   = 2'b 10; // from bus to B register. used only in LOAD instruction
parameter C_to_A    = 2'b 00; // internally move data from C to A register
parameter OUT_2_BUS = 2'b 11; // output to 256 bit out to drive databus

assign dataBus = (!nALU_Enable && outEnable == 1 && ALU_ALT == OUT_2_BUS) ? outArray : 256'bz;  

always @ (posedge reset) begin  // active high reset
	C_register [0][0] = 0;
	C_register [0][1] = 0;
	C_register [0][2] = 0;
	C_register [0][3] = 0;
	C_register [1][0] = 0;
	C_register [1][1] = 0;
	C_register [1][2] = 0;
	C_register [1][3] = 0;
	C_register [2][0] = 0;
	C_register [2][1] = 0;
	C_register [2][2] = 0;
	C_register [2][3] = 0;
	C_register [3][0] = 0;
	C_register [3][1] = 0;
	C_register [3][2] = 0;
	C_register [3][3] = 0;
	outEnable = 0; 			// ignore anything from ALU to output on bus
	end


always @ (posedge clk)
begin
	
	if (nALU_Enable == 0) begin
	case (op_code)
	NO_OP: begin
	// ignore anything from ALU output already set, will not rewrite anything or perform operations
	outEnable = 0; 
	end
	
	LOAD: begin
	//unpack
	MemArray [0][0] = dataBus [255:240]; 
	MemArray [0][1] = dataBus [239:224];
	MemArray [0][2] = dataBus [223:208];
	MemArray [0][3] = dataBus [207:192];
	MemArray [1][0] = dataBus [191:176];
	MemArray [1][1] = dataBus [175:160];
	MemArray [1][2] = dataBus [159:144];
	MemArray [1][3] = dataBus [143:128];
	MemArray [2][0] = dataBus [127:112];
	MemArray [2][1] = dataBus [111: 96];
	MemArray [2][2] = dataBus [95 : 80];
	MemArray [2][3] = dataBus [79 : 64];
	MemArray [3][0] = dataBus [63 : 48];
	MemArray [3][1] = dataBus [47 : 32];
	MemArray [3][2] = dataBus [31 : 16];
	MemArray [3][3] = dataBus [15 :  0];
	
	
	if (ALU_ALT == WRITE_A) begin// load A  
	
	A_register [0][0] = MemArray [0][0];
	A_register [0][1] = MemArray [0][1];
	A_register [0][2] = MemArray [0][2];
	A_register [0][3] = MemArray [0][3];
	A_register [1][0] = MemArray [1][0];
	A_register [1][1] = MemArray [1][1];
	A_register [1][2] = MemArray [1][2];
	A_register [1][3] = MemArray [1][3];
	A_register [2][0] = MemArray [2][0];
	A_register [2][1] = MemArray [2][1];
	A_register [2][2] = MemArray [2][2];
	A_register [2][3] = MemArray [2][3];
	A_register [3][0] = MemArray [3][0];
	A_register [3][1] = MemArray [3][1];
	A_register [3][2] = MemArray [3][2];
	A_register [3][3] = MemArray [3][3];
	outEnable = 0;
	
	$display("WRITE A");
	$display("%h %h %h %h", A_register [0][0], A_register [0][1], A_register [0][2], A_register [0][3]);
	$display("%h %h %h %h", A_register [1][0], A_register [1][1], A_register [1][2], A_register [1][3]);
	$display("%h %h %h %h", A_register [2][0], A_register [2][1], A_register [2][2], A_register [2][3]);
	$display("%h %h %h %h", A_register [3][0], A_register [3][1], A_register [3][2], A_register [3][3]);
	end
	
	else if (ALU_ALT == WRITE_B) begin// load B 
	B_register [0][0] = MemArray [0][0];
	B_register [0][1] = MemArray [0][1];
	B_register [0][2] = MemArray [0][2];
	B_register [0][3] = MemArray [0][3];
	B_register [1][0] = MemArray [1][0];
	B_register [1][1] = MemArray [1][1];
	B_register [1][2] = MemArray [1][2];
	B_register [1][3] = MemArray [1][3];
	B_register [2][0] = MemArray [2][0];
	B_register [2][1] = MemArray [2][1];
	B_register [2][2] = MemArray [2][2];
	B_register [2][3] = MemArray [2][3];
	B_register [3][0] = MemArray [3][0];
	B_register [3][1] = MemArray [3][1];
	B_register [3][2] = MemArray [3][2];
	B_register [3][3] = MemArray [3][3];
	outEnable = 0;
	
	$display("WRITE B");
	$display("%h %h %h %h", B_register [0][0], B_register [0][1], B_register [0][2], B_register [0][3]);
	$display("%h %h %h %h", B_register [1][0], B_register [1][1], B_register [1][2], B_register [1][3]);
	$display("%h %h %h %h", B_register [2][0], B_register [2][1], B_register [2][2], B_register [2][3]);
	$display("%h %h %h %h", B_register [3][0], B_register [3][1], B_register [3][2], B_register [3][3]);
	end
	
	else if (ALU_ALT == C_to_A) begin// transfer from C result to A input, no output to bus
	A_register [0][0] = C_register [0][0];
	A_register [0][1] = C_register [0][1];
	A_register [0][2] = C_register [0][2];
	A_register [0][3] = C_register [0][3];
	A_register [1][0] = C_register [1][0];
	A_register [1][1] = C_register [1][1];
	A_register [1][2] = C_register [1][2];
	A_register [1][3] = C_register [1][3];
	A_register [2][0] = C_register [2][0];
	A_register [2][1] = C_register [2][1];
	A_register [2][2] = C_register [2][2];
	A_register [2][3] = C_register [2][3];
	A_register [3][0] = C_register [3][0];
	A_register [3][1] = C_register [3][1];
	A_register [3][2] = C_register [3][2];
	A_register [3][3] = C_register [3][3];
	outEnable = 0;
	end
	
	else if (ALU_ALT == OUT_2_BUS)
	// only to be used if no math function was utilized, or math function did not output to bus such as in the case of SCAL_MUL
	// only function from LOAD that drives bus.
	outEnable = 1;

	end // end LOAD case
	

	ADD: begin
	$display ("ADD");
	C_register [0][0] = A_register [0][0] + B_register [0][0];
	C_register [0][1] = A_register [0][1] + B_register [0][1];
	C_register [0][2] = A_register [0][2] + B_register [0][2];
	C_register [0][3] = A_register [0][3] + B_register [0][3];
	C_register [1][0] = A_register [1][0] + B_register [1][0];
	C_register [1][1] = A_register [1][1] + B_register [1][1];
	C_register [1][2] = A_register [1][2] + B_register [1][2];
	C_register [1][3] = A_register [1][3] + B_register [1][3];
	C_register [2][0] = A_register [2][0] + B_register [2][0];
	C_register [2][1] = A_register [2][1] + B_register [2][1];
	C_register [2][2] = A_register [2][2] + B_register [2][2];
	C_register [2][3] = A_register [2][3] + B_register [2][3];
	C_register [3][0] = A_register [3][0] + B_register [3][0];
	C_register [3][1] = A_register [3][1] + B_register [3][1];
	C_register [3][2] = A_register [3][2] + B_register [3][2];
	C_register [3][3] = A_register [3][3] + B_register [3][3];
	outEnable = 1;
	
	$display("%h %h %h %h", C_register [0][0], C_register [0][1], C_register [0][2], C_register [0][3]);
	$display("%h %h %h %h", C_register [1][0], C_register [1][1], C_register [1][2], C_register [1][3]);
	$display("%h %h %h %h", C_register [2][0], C_register [2][1], C_register [2][2], C_register [2][3]);
	$display("%h %h %h %h", C_register [3][0], C_register [3][1], C_register [3][2], C_register [3][3]);
	end
	
	SUB: begin
	$display ("SUBTRACT");
	C_register [0][0] = A_register [0][0] - B_register [0][0];
	C_register [0][1] = A_register [0][1] - B_register [0][1];
	C_register [0][2] = A_register [0][2] - B_register [0][2];
	C_register [0][3] = A_register [0][3] - B_register [0][3];
	C_register [1][0] = A_register [1][0] - B_register [1][0];
	C_register [1][1] = A_register [1][1] - B_register [1][1];
	C_register [1][2] = A_register [1][2] - B_register [1][2];
	C_register [1][3] = A_register [1][3] - B_register [1][3];
	C_register [2][0] = A_register [2][0] - B_register [2][0];
	C_register [2][1] = A_register [2][1] - B_register [2][1];
	C_register [2][2] = A_register [2][2] - B_register [2][2];
	C_register [2][3] = A_register [2][3] - B_register [2][3];
	C_register [3][0] = A_register [3][0] - B_register [3][0];
	C_register [3][1] = A_register [3][1] - B_register [3][1];
	C_register [3][2] = A_register [3][2] - B_register [3][2];
	C_register [3][3] = A_register [3][3] - B_register [3][3];
	outEnable = 1;
	
	$display("%h %h %h %h", C_register [0][0], C_register [0][1], C_register [0][2], C_register [0][3]);
	$display("%h %h %h %h", C_register [1][0], C_register [1][1], C_register [1][2], C_register [1][3]);
	$display("%h %h %h %h", C_register [2][0], C_register [2][1], C_register [2][2], C_register [2][3]);
	$display("%h %h %h %h", C_register [3][0], C_register [3][1], C_register [3][2], C_register [3][3]);
	end

	
	SCAL_MUL: begin // just doing a subtract for now, will replace with proper scale multiply later
	// set B register to an identity matrix of value "scalefactor"
	
	// mapping of scale factor from existing inputs. use same busses as rest of instructions
	scalefactor [15:5] = 11'b 0;
	scalefactor [4 :3] = ALU_ALT;
	scalefactor [2 :0] = scale_bits;
	$display ("SCALAR MULTIPLICATION");
	// identity matrix scaling and generation
	B_register [0][0] = scalefactor;
	B_register [0][1] = 16'h 0;
	B_register [0][2] = 16'h 0;
	B_register [0][3] = 16'h 0;
	B_register [1][0] = 16'h 0;
	B_register [1][1] = scalefactor;
	B_register [1][2] = 16'h 0;
	B_register [1][3] = 16'h 0;
	B_register [2][0] = 16'h 0;
	B_register [2][1] = 16'h 0;
	B_register [2][2] = scalefactor;
	B_register [2][3] = 16'h 0;
	B_register [3][0] = 16'h 0;
	B_register [3][1] = 16'h 0;
	B_register [3][2] = 16'h 0;
	B_register [3][3] = scalefactor;
	
	C_register [0][0] = (A_register [0][0] * B_register [0][0]);
	C_register [0][1] = (A_register [0][1] * B_register [0][0]);
	C_register [0][2] = (A_register [0][2] * B_register [0][0]);
	C_register [0][3] = (A_register [0][3] * B_register [0][0]);


	C_register [1][0] = (A_register [1][0] * B_register [0][0]);
	C_register [1][1] = (A_register [1][1] * B_register [0][0]);
	C_register [1][2] = (A_register [1][2] * B_register [0][0]);
	C_register [1][3] = (A_register [1][3] * B_register [0][0]);


	C_register [2][0] = (A_register [2][0] * B_register [0][0]);
	C_register [2][1] = (A_register [2][1] * B_register [0][0]);
	C_register [2][2] = (A_register [2][2] * B_register [0][0]);
	C_register [2][3] = (A_register [2][3] * B_register [0][0]);


	C_register [3][0] = (A_register [3][0] * B_register [0][0]);
	C_register [3][1] = (A_register [3][1] * B_register [0][0]);
	C_register [3][2] = (A_register [3][2] * B_register [0][0]);
	C_register [3][3] = (A_register [3][3] * B_register [0][0]); 
	// don't want to write to bus as this operation will not have a valid address. need to use LOAD to store value elsewhere
	outEnable = 0; 
	
	$display("%h %h %h %h", C_register [0][0], C_register [0][1], C_register [0][2], C_register [0][3]);
	$display("%h %h %h %h", C_register [1][0], C_register [1][1], C_register [1][2], C_register [1][3]);
	$display("%h %h %h %h", C_register [2][0], C_register [2][1], C_register [2][2], C_register [2][3]);
	$display("%h %h %h %h", C_register [3][0], C_register [3][1], C_register [3][2], C_register [3][3]);
	end
	
	MATR_MUL: begin
	$display ("MATRIX MULTIPLY");
	C_register [0][0] = (A_register [0][0] * B_register [0][0]) + (A_register [0][1] * B_register [1][0]) + (A_register [0][2] * B_register [2][0]) + (A_register [0][3] * B_register [3][0]);
	C_register [0][1] = (A_register [0][0] * B_register [0][1]) + (A_register [0][1] * B_register [1][1]) + (A_register [0][2] * B_register [2][1]) + (A_register [0][3] * B_register [3][1]);
	C_register [0][2] = (A_register [0][0] * B_register [0][2]) + (A_register [0][1] * B_register [1][2]) + (A_register [0][2] * B_register [2][2]) + (A_register [0][3] * B_register [3][2]);
	C_register [0][3] = (A_register [0][0] * B_register [0][3]) + (A_register [0][1] * B_register [1][3]) + (A_register [0][2] * B_register [2][3]) + (A_register [0][3] * B_register [3][3]);


	C_register [1][0] = (A_register [1][0] * B_register [0][0]) + (A_register [1][1] * B_register [1][0]) + (A_register [1][2] * B_register [2][0]) + (A_register [1][3] * B_register [3][0]);
	C_register [1][1] = (A_register [1][0] * B_register [0][1]) + (A_register [1][1] * B_register [1][1]) + (A_register [1][2] * B_register [2][1]) + (A_register [1][3] * B_register [3][1]);
	C_register [1][2] = (A_register [1][0] * B_register [0][2]) + (A_register [1][1] * B_register [1][2]) + (A_register [1][2] * B_register [2][2]) + (A_register [1][3] * B_register [3][2]);
	C_register [1][3] = (A_register [1][0] * B_register [0][3]) + (A_register [1][1] * B_register [1][3]) + (A_register [1][2] * B_register [2][3]) + (A_register [1][3] * B_register [3][3]);


	C_register [2][0] = (A_register [2][0] * B_register [0][0]) + (A_register [2][1] * B_register [1][0]) + (A_register [2][2] * B_register [2][0]) + (A_register [2][3] * B_register [3][0]);
	C_register [2][1] = (A_register [2][0] * B_register [0][1]) + (A_register [2][1] * B_register [1][1]) + (A_register [2][2] * B_register [2][1]) + (A_register [2][3] * B_register [3][1]);
	C_register [2][2] = (A_register [2][0] * B_register [0][2]) + (A_register [2][1] * B_register [1][2]) + (A_register [2][2] * B_register [2][2]) + (A_register [2][3] * B_register [3][2]);
	C_register [2][3] = (A_register [2][0] * B_register [0][3]) + (A_register [2][1] * B_register [1][3]) + (A_register [2][2] * B_register [2][3]) + (A_register [2][3] * B_register [3][3]);


	C_register [3][0] = (A_register [3][0] * B_register [0][0]) + (A_register [3][1] * B_register [1][0]) + (A_register [3][2] * B_register [2][0]) + (A_register [3][3] * B_register [3][0]);
	C_register [3][1] = (A_register [3][0] * B_register [0][1]) + (A_register [3][1] * B_register [1][1]) + (A_register [3][2] * B_register [2][1]) + (A_register [3][3] * B_register [3][1]);
	C_register [3][2] = (A_register [3][0] * B_register [0][2]) + (A_register [3][1] * B_register [1][2]) + (A_register [3][2] * B_register [2][2]) + (A_register [3][3] * B_register [3][2]);
	C_register [3][3] = (A_register [3][0] * B_register [0][3]) + (A_register [3][1] * B_register [1][3]) + (A_register [3][2] * B_register [2][3]) + (A_register [3][3] * B_register [3][3]); 
	
	outEnable = 1;
	
	$display("%h %h %h %h", C_register [0][0], C_register [0][1], C_register [0][2], C_register [0][3]);
	$display("%h %h %h %h", C_register [1][0], C_register [1][1], C_register [1][2], C_register [1][3]);
	$display("%h %h %h %h", C_register [2][0], C_register [2][1], C_register [2][2], C_register [2][3]);
	$display("%h %h %h %h", C_register [3][0], C_register [3][1], C_register [3][2], C_register [3][3]);
	end
	
	TRANSPOSE: begin
	$display ("TRANSPOSE");
	C_register [0][0] = A_register [0][0];
	C_register [0][1] = A_register [1][0];
	C_register [0][2] = A_register [2][0];
	C_register [0][3] = A_register [3][0];
	
	C_register [1][0] = A_register [0][1];
	C_register [1][1] = A_register [1][1];
	C_register [1][2] = A_register [2][1];
	C_register [1][3] = A_register [3][1];
	
	C_register [2][0] = A_register [0][2];
	C_register [2][1] = A_register [1][2];
	C_register [2][2] = A_register [2][2];
	C_register [2][3] = A_register [3][2];
	
	C_register [3][0] = A_register [0][3];
	C_register [3][1] = A_register [1][3];
	C_register [3][2] = A_register [2][3];
	C_register [3][3] = A_register [3][3];
	outEnable = 1;
	
	$display("%h %h %h %h", C_register [0][0], C_register [0][1], C_register [0][2], C_register [0][3]);
	$display("%h %h %h %h", C_register [1][0], C_register [1][1], C_register [1][2], C_register [1][3]);
	$display("%h %h %h %h", C_register [2][0], C_register [2][1], C_register [2][2], C_register [2][3]);
	$display("%h %h %h %h", C_register [3][0], C_register [3][1], C_register [3][2], C_register [3][3]);
	end
	
	START: begin 
	$display ("INITIALIZING");
	// completely ignored by execution engine for this instruction
	outEnable = 0;
	end
	endcase
	
	if (ALU_ALT == OUT_2_BUS) begin
	// output any info written to C_register to databus. here is where the LOAD output alteration takes place as well, besides all math results
	
	outArray [255:240] = C_register [0][0];
	outArray [239:224] = C_register [0][1];
	outArray [223:208] = C_register [0][2];
	outArray [207:192] = C_register [0][3];
	outArray [191:176] = C_register [1][0];
	outArray [175:160] = C_register [1][1];
	outArray [159:144] = C_register [1][2];
	outArray [143:128] = C_register [1][3];
	outArray [127:112] = C_register [2][0];
	outArray [111: 96] = C_register [2][1];
	outArray [95 : 80] = C_register [2][2];
	outArray [79 : 64] = C_register [2][3];
	outArray [63 : 48] = C_register [3][0];
	outArray [47 : 32] = C_register [3][1];
	outArray [31 : 16] = C_register [3][2];
	outArray [15 :  0] = C_register [3][3];
	outEnable = 1;
	
	end
	
	end // end if
end
endmodule