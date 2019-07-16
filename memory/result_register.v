// Sergio Jimenez
// A single 256 bit register array with address 111
// This module will be used once to store the result of the program, but
// may be used as any other memory location if it does not need to be immediately
// stored in memory.
// 
// It's data bus will also tristated when not in use, and will be both the input
// and output port. 
// 
// Reset is asynchronous and resets register to all 0's
// 

`timescale 1ns/1ns
module result_reg (dataBus, address, nEnable, ReadWrite, clk, Reset);

// Input ports for memory control and clk
input ReadWrite, nEnable, clk, Reset;
input [2:0] address;

// I/O tristated bus for all data communication to other modules
inout [255:0] dataBus;

// CPU accessible register array, and output buffer array
reg [255:0] Result_array, outArray;

// Checks for the correct address each step
wire reg_select; // address select, checks for logic 111
assign reg_select = (address == 3'b 111) ? 1 : 0;


// Tristate buffer control
// Memory only writes to bus if nEnable is low and ReadWrite is high, prompting a read
// When nEnable is low, connect dataBus to internal register outArray which has the 
// data from the requested address, otherwise tristate
assign dataBus = (!nEnable && ReadWrite && reg_select) ? outArray : 256'bz;


// Asynchronous reset
always @ (Reset)
	if (Reset)
		Result_array = 256'h 0;
		

// Read
// positive edge clock read when ReadWrite is high and nEnable is low
always @ (posedge clk)	
	if (ReadWrite && !nEnable && reg_select)	
		outArray = Result_array;  // performs a read


// Write
// negative edge clock read when Read Write is low and nEnable is low
always @ (negedge clk)
	if (!ReadWrite && !nEnable && reg_select)
		Result_array = dataBus;


endmodule
