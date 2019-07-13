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
// 111 STOP
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
module execution_engine ();
input wire [8:0] inst_mem;
input reset, clk;
output reg [5:0] program_address; // emulating the input of the instruction memory
reg [2:0] op_code, destination, source;

	
// Parsing the instruction memory to internal registers
op_code     = inst_mem [8:6];
destination = inst_mem [5:3];
source      = inst_mem [2:0];

always @ (posedge reset)
	program_address = 6'b 0;
	
	
always @ (posedge clk)
	begin
		case (op_code)
	
	
	end
	
endmodule	
	
