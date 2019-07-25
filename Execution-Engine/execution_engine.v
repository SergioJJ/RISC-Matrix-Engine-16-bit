// Sergio Jimenez
// Execution Engine
// Simplified model for an execution engine, will have these operations defined.
// OPCODES
// 000 NO-OP
// 001 LOAD
// 010 ADD
// 011 SUB
// 100 SCAL MUL
// 101 MATR MUL
// 110 TRANSPOSE
// 111 STORE  
// 
// Will have 9 bit input bus instead of instruction memory to be driven by the testbench.
// OPCODE  DEST  SOURCE1  
// XXX     XXX   XXX 
// 
//
// Takes in 3 bit Opcodes and decodes info that controls outside modules that the opcodes refer to.
// Simplified one bit select actions will be used for this assignment. More complex state output will be
// nescessary when implementing with RAM and ALU modules.
// Will have a built in program counter that will point to the correct instruction address in the instruction memory.


`timescale 1ns/1ns
module execution_engine 
(program_address, nMem_Enable, nALU_Enable, mem_RW, 
op_select, mem_address, ALU_address, inst_mem, reset, clk);

input wire [8:0] inst_mem;  // each instruction is 9 bits
input reset, clk;
output reg [5:0] program_address; // emulating the input of the instruction memory
output reg nMem_Enable, nALU_Enable, mem_RW;
// don't really need the extra opcode register as it serves a buffer for the passthrough to the ALU, but 
// helps with knowing when this data is being looked at
output reg [2:0] op_select, mem_address, ALU_address; 

wire [2:0] op_code, destination, source;
reg [7:0] CURRENT_STATE, NEXT_STATE;

	
// Parsing the instruction memory to internal registers
assign op_code     = inst_mem [8:6];
assign destination = inst_mem [5:3];
assign source      = inst_mem [2:0];

// official opcode definitions, will be used for decode state
parameter NO_OP     = 3'b 000;
parameter LOAD      = 3'b 001;
parameter ADD       = 3'b 010;
parameter SUB       = 3'b 011;
parameter SCAL_MUL  = 3'b 100;
parameter MATR_MUL  = 3'b 101;
parameter TRANSPOSE = 3'b 110;
parameter STORE     = 3'b 111; 

// microcode definitions
parameter INST        = 8'h 00;
parameter DECODE      = 8'h 10;
parameter LOAD_START  = 8'h 20;
parameter READ_MEM    = 8'h 21;
parameter CLEAN_READ  = 8'h 22;
parameter STORE_START = 8'h 30;
parameter STORE_RES   = 8'h 31;
parameter MATH        = 8'h 40;
parameter MATH_CLEAN  = 8'h 41;




always @ (posedge reset) begin
	program_address = 6'b 0;
	CURRENT_STATE = INST;
	end
	
always @ (posedge clk)
	begin
	
	case (CURRENT_STATE)

	INST: begin
		program_address = program_address + 1;  // program counter
		NEXT_STATE = DECODE;
		end

	
	DECODE: begin
		if (op_code == NO_OP) begin // don't do anything, wait a clock cycle
		nMem_Enable = 1; // disable memory and register
		nALU_Enable = 1; // disable ALU
		mem_address = 0; // default mem address
		op_select    = op_code; // passthrough to ALU
//		NEXT_STATE = CURRENT_STATE;
		NEXT_STATE = INST;
		end
		
		else if (op_code == LOAD) // STOP program from continuing
		NEXT_STATE = LOAD_START;
		
		else if (op_code == STORE)
		NEXT_STATE = STORE_START;
		
		else
		NEXT_STATE = MATH;

		end // end DECODE
	
	LOAD_START: begin  // will load matrix from memory and put it into register A or B
		mem_address  = source;
		ALU_address  = destination;
		op_select    = op_code;  // this opcode will tell ALU what to do with what's on the bus when it's enabled
		mem_RW       = 1; // performing a read
		nMem_Enable  = 1; // active low
		nALU_Enable  = 1; // both modules we are interfacing with are disabled
		NEXT_STATE   = READ_MEM;
		end
	
	READ_MEM: begin
		nMem_Enable  = 0; // memory outputs data on bus
		nALU_Enable  = 0; // ALU reads data into 
		NEXT_STATE   = CLEAN_READ;
		end
		
	CLEAN_READ: begin
		mem_address = 3'b 000;
		nMem_Enable = 1; // disable memory after reading
		nALU_Enable = 1; // disable ALU after writing to ALU's A or B registers
//		NEXT_STATE = DECODE;
		NEXT_STATE  = INST;
		end
	
	STORE_START: begin
		mem_address = destination;
		ALU_address = source;
		op_select = op_code;  // will tell ALU that we will be reading from its C register
		mem_RW = 0; // performing a write
		nMem_Enable = 1;
		nALU_Enable = 1;
		NEXT_STATE = STORE_RES;
		end
		
	STORE_RES: begin
		nMem_Enable = 0; // memory outputs data on bus
		nALU_Enable = 0; // ALU reads data into 
		NEXT_STATE = CLEAN_READ; // would have been virtually identical
		end
	
	MATH: begin
		op_select = op_code;
		nALU_Enable = 0;
		nMem_Enable = 0;
		NEXT_STATE = MATH_CLEAN;
		end
		
	MATH_CLEAN: begin
		nALU_Enable = 1;
		nMem_Enable = 1;  //disable everything
		NEXT_STATE = INST;
//		NEXT_STATE = DECODE;
		
		end
		
		endcase	
	CURRENT_STATE = NEXT_STATE;

	end
	
endmodule
