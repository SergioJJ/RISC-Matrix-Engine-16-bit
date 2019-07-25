// Sergio Jimenez
// This is the testbench for the execution engine for this project. 
// This simulates the program register and some dummy instructions to feed to test the output.

`timescale 1ns/1ns
module ex_eng_testbeng;

// TESTBENCH VARIABLES
reg [8:0] inst_mem;
reg reset, clk;

wire [5:0] program_address;
wire [2:0] op_select, mem_address, ALU_address; 
wire nMem_Enable, nALU_Enable, mem_RW;

execution_engine V16_ENGINE (program_address, nMem_Enable, nALU_Enable, mem_RW, op_select, mem_address, ALU_address, inst_mem, reset, clk);

always
begin
clk = 0;
	forever
	clk = #5 !clk;
end

initial
begin
	reset = 0;
	inst_mem = 9'o 012; // testing no-op
	
	#5
	reset = 1;
	
	#5
	reset = 0;
	
	#10
	inst_mem = 9'o 162; // load address 2, ALU will do something
	
	#20
	inst_mem = 9'o 245; 
	
	#20
	inst_mem = 9'o 725;
	
	#20
	inst_mem = 9'o 434;
	
	#20
	inst_mem = 9'o 177;
	
	#20
	inst_mem = 9'o 000;
	
	
	
end
endmodule
