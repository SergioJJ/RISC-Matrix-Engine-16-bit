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
// Page used below for reference
// http://www.asic-world.com/examples/verilog/ram_sp_sr_sw.html

module memory (dataBus, address, nEnable, ReadWrite, clk);

	
// Input Ports for memory control and clk
input	ReadWrite, nEnable, clk;
input	[3:0] address;
	
// I/O tristated bus for all communication to other modules
inout 	[255:0] dataBus; 

// Memory block containing 8 addresses, 256 bits deep
reg [255:0] MemArray[0:7]; 
	
// Internal registers directing read data
reg  [255:0] outArray;

    
// Tristate buffer control
// Memory only writes to bus if nEnable is low and ReadWrite is high, prompting a read
// When nEnable is low, connect dataBus to internal register outArray which has the 
// data from the requested address, otherwise tristate
assign dataBus = (!nEnable && !ReadWrite) ? outArray : 256'bz;
	


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

		
		
		
