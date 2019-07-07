// Sergio Jimmenez
// 8 address 256 bit memory
// This module will utilize a single 256 bit I/O Bus which will be tristated when not in use.
// 
// 
// Route data to/from memory array as per ReadWrite bit
// ReadWrite 1 = Read from memory; at risingedge
// ReadWrite 0 = Write to memory;  at falling edge
//
// nEnable is active low, this allows data to be either written 
// or read from at the respective clock edge dependent on the ReadWrite signal
//
// Reset is asynchronous and resets entire memory block to all 0's
//
// Page used below for reference
// http://www.asic-world.com/examples/verilog/ram_sp_sr_sw.html
`timescale 1ns/1ns
module memory (dataBus, address, nEnable, ReadWrite, clk, Reset);

	
// Input Ports for memory control and clk
input	ReadWrite, nEnable, clk, Reset;
input	[7:0] address;
	
// I/O tristated bus for all communication to other modules
inout 	[255:0] dataBus; 

// Memory block containing 8 addresses, 256 bits deep
reg [255:0] MemArray[0:7]; 
	
// Internal registers directing read data
reg  [255:0] outArray;

// Reset control logic, sets all data registers to zero when Reset goes high
always @ (Reset)
begin
	if (Reset)
	begin 
		MemArray [0] = 	256'b0;
		MemArray [1] = 	256'b0;
		MemArray [2] = 	256'b0;
		MemArray [3] = 	256'b0;
		MemArray [4] = 	256'b0;
		MemArray [5] = 	256'b0;
		MemArray [6] = 	256'b0;
		MemArray [7] = 	256'b0;
	end
end	
    
// Tristate buffer control
// Memory only writes to bus if nEnable is low and ReadWrite is high, prompting a read
// When nEnable is low, connect dataBus to internal register outArray which has the 
// data from the requested address, otherwise tristate
assign dataBus = (!nEnable && ReadWrite) ? outArray : 256'bz;
	


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

		
		
		
