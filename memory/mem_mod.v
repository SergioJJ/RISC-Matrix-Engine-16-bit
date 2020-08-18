// Sergio Jimmenez
// 7 address 256 bit memory
// This module will utilize a single 256 bit I/O Bus which will be tristated when not in use.
// Addresses 0 - 5 will be used for system memory directly in the RAM, addresses 
// Address location will be reserved for the Result Register module
// 
// Route data to/from memory array as per ReadWrite bit
// ReadWrite 1 = Read from memory; at risingedge
// ReadWrite 0 = Write to memory;  at falling edge
//
// nEnable is active low, this allows data to be either written 
// or read from at the respective clock edge dependent on the ReadWrite signal
//
// Reset is asynchronous and resets reuseable memory block to all 0's
//
// Page used below for reference
// http://www.asic-world.com/examples/verilog/ram_sp_sr_sw.html
// 
// Matrix A data
// Decimal     4   12    4   34    7    6   11    9    9    2    8   13    2   15   16    3
// 256'h_   0004_000c_0004_0022_0007_0006_000b_0009_0009_0002_0008_000d_0002_000f_0010_0003;
//  
// Matrix B data
// Decimal    23   45   67   22    7    6    4    1   18   56   13   12    3    5    7    9
// 256'h_   0017_002d_0043_0016_0007_0006_0004_0001_0012_0038_000d_000c_0003_0005_0007_0009;


`timescale 1ns/1ns
module memory (dataBus, address, nEnable, ReadWrite, clk, Reset);


// Input Ports for memory control and clk
input	ReadWrite, nEnable, clk, Reset;
input	[2:0] address;
	
// I/O tristated bus for all data communication to other modules
inout 	[255:0] dataBus; 

// Memory block containing 7 addresses, 256 bits deep
// Address 8 reserved for result register
reg [255:0] MemArray [0:6]; 
	
// Internal registers directing read data
reg  [255:0] outArray;

// Checks for the correct addresses each step
wire add_enable; // checks for valid addresses, 0 - 6;
assign add_enable = address == (3'b111) ? 0 : 1;

/* quick reference
0    0000
1    0001
2    0010
3    0011
4    0100
5    0101
6    0110
7    0111
8    1000
9    1001
A 10 1010
B 11 1011
C 12 1100
D 13 1101
E 14 1110
F 15 1111

*/

// 256'h_28_31_5b_2b_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00;

// write instruction program here
// instruciton address         0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
parameter INSTRUCTIONS = 256'h_28_31_5b_2b_30_7c_2c_dd_2d_88_3f_2f_35_be_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00;
//    INSTRUCTIONS DATA GUIDE
//		  0  LOAD A   zero  
// 28        001  01  000   
//		  1	 LOAD B   one   
// 31        001  10  001   
// 		  2  ADD  bus three 
// 5b        010  11  011   
// 		  3  LOAD A   three 
// 2b        001  01  011   
//		  4  LOAD B   zero  
// 30        001  10  000   
//		  5  SUB  bus four  
// 7c        011  11  100      
//		  6  LOAD A   four  
// 2c        001  01  100   
//		  7  TRAN bus five  
// dd        110  11  101  
//		  8	 LOAD A   five
// 2d        001  01  101   
// 		  9  SCALE  8  
// 88        100  01000   //hmm
// 		  10 LOAD bus  seven // to register
// 3f        001  11  111   
// 		  11 LOAD A   seven   
// 2f        001  01  111   
// 		  12 LOAD B   five
// 35        001  10  101
// 		  13 MULT bus  six
// be        101  11  110
// 		  14 STOP/NO_OP
// 00        000  00  000
// 		  15
//00_        XXX  XX  XXX
// 		  16
//00_        XXX  XX  XXX
// 		  17
//00_        XXX  XX  XXX
// 		  18
//00_        XXX  XX  XXX
//		  19
//00_        XXX  XX  XXX
// 		  20
//00_        XXX  XX  XXX
// 		  21
//00_        XXX  XX  XXX
// 		  22
//00_        XXX  XX  XXX
// 		  23
//00_        XXX  XX  XXX
// 		  24
//00_        XXX  XX  XXX
// 		  25
//00_        XXX  XX  XXX
// 		  26
//00_        XXX  XX  XXX
// 		  27
//00_        XXX  XX  XXX
// 		  28
//00_        XXX  XX  XXX
// 		  29
//00_        XXX  XX  XXX
// 		  30
//00_        XXX  XX  XXX   
// 		  31
//00;        XXX  XX  XXX
	  
// Reset control logic, sets all data registers to zero when Reset goes high
always @ (Reset)
begin
	if (Reset)
	begin 
		MemArray [0] = 	256'h_0004_000c_0004_0022_0007_0006_000b_0009_0009_0002_0008_000d_0002_000f_0010_0003;  // Matrix 0
		MemArray [1] = 	256'h_0017_002d_0043_0016_0007_0006_0004_0001_0012_0038_000d_000c_0003_0005_0007_0009;  // Matrix 1
		MemArray [2] = 	INSTRUCTIONS;  // Instruction memory slot
		MemArray [3] = 	256'b0;
		MemArray [4] = 	256'b0;
		MemArray [5] = 	256'b0;
		MemArray [6] = 	256'b0;
//		MemArray [7] = 	256'b0;  // Separate Result register, address 111
	end
end	
// Tristate buffer control
// Memory only writes to bus if nEnable is low and ReadWrite is high, prompting a read
// When nEnable is low, connect dataBus to internal register outArray which has the 
// data from the requested address, otherwise tristate
assign dataBus = (!nEnable && ReadWrite && add_enable) ? outArray : 256'bz;



// Read
// positive edge clock read when ReadWrite is high and nEnable is low
always @ (posedge clk)
begin
	if (ReadWrite && !nEnable)	
		outArray = MemArray [address];  // performs a read
end
	
// Write
// negative edge clock read when Read Write is low and nEnable is low
always @ (negedge clk)
begin
	if (!ReadWrite && !nEnable)
		MemArray [address] = dataBus;
end

endmodule


