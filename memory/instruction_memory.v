// Sergio Jimenez
// This is 8 bit storage for the execution engine.
// This module will sit inside the execution engine and be used to pull instructions into it
// via the program counter. 
//
// 8 bit instruction memory will support 32 addresses per 256 bit read in.
// 
// At initial startup, the execution engine will read an address in RAM with the instruction
// data in it in a single 256 bit word, and will parse each instruction into this memory from
// this 256 bit read. 
// 
// This is Write once, Read only memory. Reset will set all interal registers to 0, and can be
// reloaded with more instructions to run another program.
// 
// All bits in a 256 bit word will be used for 32 instructions.
// 

`timescale 1ns/1ns
module instruction_memory (dataBus, inst_read, inst_address, load_instrs, clk, Reset);

// Input ports
input      load_instrs, clk, Reset;
input      [4 :0] inst_address; // pulls instruction nescessary for execution
input      [255:0] dataBus; // writes code 

// Output port
// Current state instruction
output reg [7  :0] inst_read;


// 42 X 12 bit memory block
reg [7:0] MemArray [0:31]; 



always @ (posedge Reset)
begin
	MemArray [0]  = 0; // program address 1
	MemArray [1]  = 0;
	MemArray [2]  = 0;
	MemArray [3]  = 0;
	MemArray [4]  = 0;
	MemArray [5]  = 0;
	MemArray [6]  = 0;
	MemArray [7]  = 0;
	MemArray [8]  = 0;
	MemArray [9]  = 0;
	MemArray [10] = 0;
	MemArray [11] = 0;
	MemArray [12] = 0;
	MemArray [13] = 0;
	MemArray [14] = 0;
	MemArray [15] = 0;
	MemArray [16] = 0;
	MemArray [17] = 0;
	MemArray [18] = 0;
	MemArray [19] = 0;
	MemArray [20] = 0;
	MemArray [21] = 0;
	MemArray [22] = 0;
	MemArray [23] = 0;
	MemArray [24] = 0;
	MemArray [25] = 0;
	MemArray [26] = 0;
	MemArray [27] = 0;
	MemArray [28] = 0;
	MemArray [29] = 0;
	MemArray [30] = 0;
	MemArray [31] = 0;
end

always @ (posedge load_instrs)
begin
	MemArray [0]  = dataBus [255:248]; // program address 1
	MemArray [1]  = dataBus [247:240];
	MemArray [2]  = dataBus [239:232];
	MemArray [3]  = dataBus [231:224];
	MemArray [4]  = dataBus [223:216];
	MemArray [5]  = dataBus [215:208];
	MemArray [6]  = dataBus [207:200];
	MemArray [7]  = dataBus [199:192];
	MemArray [8]  = dataBus [191:184];
	MemArray [9]  = dataBus [183:176];
	MemArray [10] = dataBus [175:168];
	MemArray [11] = dataBus [167:160];
	MemArray [12] = dataBus [159:152];
	MemArray [13] = dataBus [151:144];
	MemArray [14] = dataBus [143:136];
	MemArray [15] = dataBus [135:128];
	MemArray [16] = dataBus [127:120];
	MemArray [17] = dataBus [119:112];	
	MemArray [18] = dataBus [111:104];
	MemArray [19] = dataBus [103: 96];
	MemArray [20] = dataBus [95 : 88];
	MemArray [21] = dataBus [87 : 80];
	MemArray [22] = dataBus [79 : 72];             
	MemArray [23] = dataBus [71 : 64];
	MemArray [24] = dataBus [63 : 56];
	MemArray [25] = dataBus [55 : 48];
	MemArray [26] = dataBus [47 : 40];
	MemArray [27] = dataBus [39 : 32];
	MemArray [28] = dataBus [31 : 24];
	MemArray [29] = dataBus [23 : 16];
	MemArray [30] = dataBus [15 :  8];
	MemArray [31] = dataBus [7  :  0];
	

end
///*
always @ (posedge clk) 
	if (!load_instrs)
	inst_read = MemArray [inst_address];
//*/
//assign inst_read = (!load_instrs) ? MemArray[inst_address] : 8'b x;

endmodule



