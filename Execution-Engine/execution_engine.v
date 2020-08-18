// Sergio Jimenez
// 8 bit instruction Execution Engine
// Instruction "pre-fetch" feed in from momory address defined by instruction
//
// Supported instruction set with address intent
// OPCODE  ALT   SOURCE1  
// XXX     XX    XXX 
//
//
// OPCODES         ALTERATION                        ADDRESS			| Description
// 000 NO-OP       ---------------------------------------------------- | --------------------------------------------------------
//				   N/A								 N/A				| Waits one clock cycle. Leaves everything as is
// 				   														|
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
//																		|
// 101 MATR MUL    ---------------------------------------------------- | --------------------------------------------------------
//				   00 C Register to A Register		 3 bit destination  | Internal movement from result to A register
//				   11 C Register to dataBus								| Dump whatever is in C register to bus
//																		|
// 110 TRANSPOSE   ---------------------------------------------------- | --------------------------------------------------------
//				   00 C Register to A Register		 3 bit destination  | Internal movement from result to A register
//				   11 C Register to dataBus								| Dump whatever is in C register to bus
//																		|
// 111 START 	   ---------------------------------------------------- | --------------------------------------------------------
//				   N/A								 3 bit source       | Pulls in instructions and sorts into instruction memory
// 
// 


`timescale 1ns/1ns
module execution_engine (inst_mem, mem_address, program_address, op_select, load_instrs, ALU_ALT, nMem_Enable, nALU_Enable, mem_RW, clk, reset);

// CURRENT_STATE input along with reset and clk
input wire [7:0] inst_mem;  // instruction fed into Ex Eng, each instruction is 8 bits
input reset, clk;

// Output signals and busses
output reg [4:0] program_address; //points to the address of current state instruction
output reg nMem_Enable, nALU_Enable, mem_RW, load_instrs;
output reg [2:0] op_select, mem_address;
output reg [1:0] ALU_ALT;

// official opcode definitions, will be used for decode state
parameter NO_OP     = 3'b 000;
parameter LOAD      = 3'b 001;
parameter ADD       = 3'b 010;
parameter SUB       = 3'b 011;
parameter SCAL_MUL  = 3'b 100;
parameter MATR_MUL  = 3'b 101;
parameter TRANSPOSE = 3'b 110;
parameter START     = 3'b 111; 

// microcode definitions
parameter INST        = 8'h 00;
parameter DECODE      = 8'h 10;
parameter LOAD_START  = 8'h 20;
parameter READ_MEM    = 8'h 21;
parameter CLEAN_READ  = 8'h 22;
parameter START_START = 8'h 30; // loads instructions into instruction memory, can be triggered by reset
parameter START_STORE = 8'h 31; // saves instructions to instruction memory
parameter MATH        = 8'h 40;
parameter MATH_STORE  = 8'h 41;
parameter MATH_CLEAN  = 8'h 42;
parameter SCALE_GEN   = 8'h 43; // still a math operation
parameter SCALE_EXE   = 8'h 44;

// alteration definitions
parameter WRITE_A   = 2'b 01; // from bus to A register. used only in LOAD instruction
parameter WRITE_B   = 2'b 10; // from bus to B register. used only in LOAD instruction
parameter C_to_A    = 2'b 00; // internally move data from C to A register
parameter OUT_2_BUS = 2'b 11; // output to 256 bit out to drive databus

// to be used when calling an address from memory
parameter zero  = 3'b 000; 
parameter one   = 3'b 001;
parameter two   = 3'b 010;
parameter three = 3'b 011;
parameter four  = 3'b 100;
parameter five  = 3'b 101;
parameter six   = 3'b 110;
parameter seven = 3'b 111;

wire inst_ignore; // toggles high when reset is active
reg [2 : 0] op_code, source;
reg [1 : 0] alteration;
reg  [7 : 0] CURRENT_STATE, NEXT_STATE;

// this is an attempt to fix the issue with the reset losing it's track if 
// the memory and alu alteration are updated at clock edge
assign inst_ignore = CURRENT_STATE == (START_START | START_STORE) ? 1 : 0;


always @ (posedge reset) begin
	CURRENT_STATE   = START_START;
	end
	
always @ (posedge clk)
	begin
	
	if (inst_ignore == 0) begin
	op_code    = inst_mem [7:5];
	alteration = inst_mem [4:3];
    source     = inst_mem [2:0];
	end
	
	case (CURRENT_STATE)

	INST: begin 
		nMem_Enable = 1; 				// disable memory and register
		nALU_Enable = 1; 				// disable ALU
		load_instrs     = 0;  			// resets value if set high from last START instruction
		op_select   = op_code;   		// will alway be set, ALU will ignore automatically if code not supported
		ALU_ALT     = alteration; 		// set for LOAD, and all math. further decode of SCAL_MUL happens in ALU
		mem_address = source;     		// set for LOAD, and all math. further decode of SCAL_MUL happens in ALU
		NEXT_STATE = DECODE;
		end

	
	DECODE: begin //testable, temporarily changing from DECODE to INST
		if (op_code == NO_OP) begin 	// don't do anything, wait a clock cycle
		op_select   = op_code;   		// will alway be set, ALU will ignore automatically if code not supported
		ALU_ALT     = alteration; 		// set for LOAD, and all math. further decode of SCAL_MUL happens in ALU
		mem_address = source;     		// set for LOAD, and all math. further decode of SCAL_MUL happens in ALU
		load_instrs     = 0; 			// resets value if set high from last START instruction
		nMem_Enable = 1; 				// disable memory and register
		nALU_Enable = 1; 				// disable ALU
		mem_address = zero; 			// default mem address

		NEXT_STATE = INST;
		end // end NO_OP definitions
		
		else if (op_code == LOAD) 		// load a single address into ALU
		NEXT_STATE = LOAD_START;
		
		else if (op_code == START)		// load instructions into instruction memory from RAM
		NEXT_STATE = START_START;
		// all maths follow
		else if (op_code == SCAL_MUL)	// generate a scalar multiplication factor
		NEXT_STATE = SCALE_GEN;
		
		else if (op_code == ADD)
		NEXT_STATE = MATH;
		
		else if (op_code == SUB)
		NEXT_STATE = MATH;	
		
		else if (op_code == MATR_MUL)
		NEXT_STATE = MATH;	
		
		else if (op_code == TRANSPOSE)
		NEXT_STATE = MATH;	
		
		end // end DECODE
	
	LOAD_START: begin  
	// will load matrix from memory and put it into register A or B
	// memory address and ALU instruction already set
		mem_address = source;    		
		ALU_ALT     = alteration;		
		op_select   = op_code;   

		
		if (ALU_ALT == 2'b 11) begin
		NEXT_STATE = MATH_STORE;
		mem_RW      = 0;
		nMem_Enable = 1;
		nALU_Enable = 0;
		end
		else begin
		NEXT_STATE   = READ_MEM;
		mem_RW      = 1;
		nMem_Enable = 0;
		nALU_Enable = 1;
		end
		
		end
	
	
	READ_MEM: begin // 
		mem_address = source;    		
		ALU_ALT     = alteration;		
		op_select   = op_code;   
		nMem_Enable  = 0; // memory outputs data on bus
		nALU_Enable  = 0; // ALU reads data into 
		NEXT_STATE   = CLEAN_READ;
		end
		
	CLEAN_READ: begin
		mem_address = zero; // default mem address
		nMem_Enable = 1; // disable memory after reading
		nALU_Enable = 1; // disable ALU after writing to ALU's A or B registers
		program_address = program_address + 1;  // added in for now
		NEXT_STATE  = INST;
		end

	START_START: begin 
	// will load instructions from dedicated instruction address 2.
	// will jump here directly from reset or can be called in via program.
	// ALU address and opcoode ignored for this instruction, doesn't use ALU
		program_address = 5'b 11111; // INST will rollover into 0 address.
		mem_address = two;  //default instruction address
		mem_RW = 1; // performing a read from memory
		nMem_Enable = 0;
		nALU_Enable = 1;
		load_instrs = 0; // load activated
		NEXT_STATE = START_STORE;
		end
	
	START_STORE: begin // enables memory and instruction memory copy
		nMem_Enable = 0; 
		load_instrs = 1; 
		program_address = program_address + 1;  // added in for now
		NEXT_STATE  = INST; // INST will reset all values toggled to a known default state
		end
		
		
	SCALE_GEN: begin  
	// fundamentally different instruction, but execution engine sees it identically as a math function. 
	// will load defined scalefactor value coming in through already set ALU_ALT and mem_address values
	// OPCODE  SCALEVALUE (0 - 31)     SCALUEVALUE = ALU_ALT in series with mem_address
	// 100     XXXXX   
		op_select   = op_code;
		mem_address = source;    		
		ALU_ALT     = alteration;
		nMem_Enable = 1; // memory not used at all this isntruciton
		nALU_Enable = 0; // just setting up data first to hold into SCALE_EXE
		NEXT_STATE = MATH_CLEAN; 
		end

	MATH: begin  // assumes data is already in there
		op_select   = op_code;
		mem_address = source;    		
		ALU_ALT     = alteration;				
		nALU_Enable = 0;
		nMem_Enable = 1;
		NEXT_STATE = MATH_STORE;
		end
		
	MATH_STORE: begin
		mem_RW = 0; // writing to memory
		nMem_Enable = 0; // start the write
		nALU_Enable = 0; // continued from last state
		NEXT_STATE = MATH_CLEAN;
		end
		
	MATH_CLEAN: begin
		nALU_Enable = 1;
		nMem_Enable = 1;  //disable everything
		program_address = program_address + 1;  // added in for now
		NEXT_STATE = INST;
		end

		
		endcase	
	CURRENT_STATE = NEXT_STATE;

	end
	
endmodule