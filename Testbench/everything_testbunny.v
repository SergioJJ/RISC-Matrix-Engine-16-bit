// Sergio Jimenez
// Testbench for main RAM, Result Register and INST memory modules
// An initial write into the memory will take place into a few addresses.
// RAM address 2 will contain instructions in a defined format to be written
// into the INST memory. The INST address will be driven by the
// testbench and will display first few addresses in the INST memory
// while RAM reading and Result Register reading occur simultaneously.

`timescale 1ns/1ns
module RISC_testbench;


// dataBus          -- 256 bit interconnect
wire [255:0] dataBus;

// inst_read        -- 8 output bits from inst mem
wire [7:0] inst_read;

// op_code     -- code to alu about operations 
// address_select   -- memory or register address
// ALU_control      -- 3 bit ALU input bus
wire [2:0] op_code, address_select;
wire [1:0] ALU_control;

// program_address  -- address in inst memory
wire [4:0] program_address;


// load_instrs      -- write from input bus to inst memory 
// nMem_Enable      -- enable for memory and register
// mem_RW           -- read/write select memory and enable
wire load_instrs, nMem_Enable, mem_RW;


// INPUTS
// clk              -- 10 ns perios    Reset            -- reload instruction memory
reg clk, Reset;            


// Port label               dataBus  inst_read  address_select  program_address  op_code  load_instrs  ALU_control  nMem_Enable  nALU_Enable  mem_RW  clk   Reset 
// Interconnect width       256bit   9 bit      3 bit           6 bit            3 bit    1 bit        3 bit        1 bit        1 bit        1 bit   1 bit 1 bit
// I/O                      wire/out wire       wire            wire             wire     wire         wire         wire         wire         wire    in    in

execution_engine the_brain (         inst_read, address_select, program_address, op_code, load_instrs, ALU_control, nMem_Enable, nALU_Enable, mem_RW, clk,  Reset);                   
ALU the_math               (dataBus,            address_select,                  op_code,              ALU_control,              nALU_Enable,         clk,  Reset);
instruction_memory INST    (dataBus, inst_read,                 program_address,          load_instrs,                                                clk,  Reset);
memory     RAM             (dataBus,            address_select,                                                     nMem_Enable,              mem_RW, clk,  Reset);
result_reg Register        (dataBus,            address_select,                                                     nMem_Enable,              mem_RW, clk,  Reset);

// notes - address select going into the ALU is for exclusive use for the scalefactor function

// tic toc said the clock
always
begin	
	clk = 0;
	forever
		clk = #5 !clk; // 10 ns period clock
end



initial
begin
	Reset = 0;
	
	#5
	Reset = 1;
	
	#3 
	Reset = 0;
	
	
end	
	
// initial	
//  	$monitor ("Time %t  Reset: %b  nEnable: %b  ReadWrite: %b  CLK: %b  ADD [%h] Data In: %d Data Bus: %d", 
//	$stime,  Reset, nEnable, ReadWrite, clk, address_select, dataIN, dataBus);
	
endmodule	//that's it