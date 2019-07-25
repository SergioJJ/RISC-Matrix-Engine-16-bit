// Sergio Jimenez
// Testbench to test ALU for HW assigment for a matrix multiplier
// Will use system architecture to simulate instructions from Execution engine to control ALU
// 
// LOAD REG_A ADDRESS 0  *memory not actually being called, just simulated by testbench
// 001  001   000
// 
// LOAD REG_B ADDRESS 1
// 001  100   001
// 
// MATR OUT   ADDRESS 2  *multiplication doesn't have additional info, output of mult will go to dataBus due to OUT modifier
// 101  111   010        *ideally, will have RAM writing this info
// 
// Matrix 1
// 5	8	6	2
// 7	3	8	4
// 6	5	1	3
// 8	5	7	9
// 256'h 0005_0008_0006_0002_0007_0003_0008_0004_0006_0005_0001_0003_0008_0005_0007_0009; 
//
// 
// Matrix 2
// 11	14	19	18
// 6	9	4	5
// 12	10	15	14
// 6	3	8	7
// 256'h 000b_000e_0013_0012_0006_0009_0004_0005_000c_000a_000f_000e_0006_0003_0008_0007;


`timescale 1ns/1ns
module ALU_TESTMONKEY;

reg [2:0] op_code, ALU_control;
reg reset, clk, nALU_Enable;
reg [255:0] dataIN;
wire [255:0] dataBus;

ALU matrix_mult (dataBus, op_code, ALU_control, reset, clk, nALU_Enable);

assign dataBus = dataIN;

always
begin
	clk = 0;
	forever
		clk = #5 !clk; // 10 ns period clock
end

initial
begin
	reset       = 0;
	nALU_Enable = 1;
	op_code     = 3'b 001; // load
	ALU_control = 3'b 001; // A register
	dataIN = 256'h 0005_0008_0006_0002_0007_0003_0008_0004_0006_0005_0001_0003_0008_0005_0007_0009;
	
	#5
	reset       = 1;
	
	#4
	reset       = 0;
	nALU_Enable = 0; // writing value matrix 1 into internal register A
	#1
	
	#10
	op_code     = 3'b 001; // load
	ALU_control = 3'b 100; // B register
	dataIN = 256'h 000b_000e_0013_0012_0006_0009_0004_0005_000c_000a_000f_000e_0006_0003_0008_0007;
	
	#10
	op_code     = 3'b 000;
	dataIN = 256'h z;
	
	#10

	op_code     = 3'b 101;
	ALU_control = 3'b 111;
	
	
	
	
end

initial
	$monitor ("Time %t dataBus %h", $stime, dataBus);

endmodule
