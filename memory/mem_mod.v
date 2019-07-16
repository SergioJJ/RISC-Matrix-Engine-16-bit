// Sergio Jimmenez
// 6 address 256 bit memory
// This module will utilize a single 256 bit I/O Bus which will be tristated when not in use.
// Addresses 0 - 5 will be used for system memory directly in the RAM, addresses 
// 6 and 7 will be reserved for other actions.
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
// 256'h_0003_0010_000f_0002_000d_0008_0002_0009_0009_000b_0006_0007_0022_0004_000c_0004;
// Matrix B data
// 256'h_0009_0007_0005_0003_000c_000d_0038_0012_0001_0004_0006_0007_0016_0043_002d_0017;

`timescale 1ns/1ns
module memory (dataBus, address, nEnable, ReadWrite, clk, Reset);


// Input Ports for memory control and clk
input	ReadWrite, nEnable, clk, Reset;
input	[2:0] address;
	
// I/O tristated bus for all data communication to other modules
inout 	[255:0] dataBus; 


// Memory block containing 6 addresses, 256 bits deep
reg [255:0] MemArray [0:5]; 
	
// Internal registers directing read data
reg  [255:0] outArray;





// Checks for the correct addresses each step
wire add_enable; // checks for valid addresses, 0 - 6;
assign add_enable = (address == (3'b111 | 3'b110)) ? 0 : 1;








// Reset control logic, sets all data registers to zero when Reset goes high
always @ (Reset)
begin
	if (Reset)
	begin 
//		MemArray [0] = 	256'b0;  // Matrix 0
//		MemArray [1] = 	256'b0;  // Matrix 1
//		MemArray [2] = 	256'b0;  // Instruction memory
		MemArray [3] = 	256'b0;
		MemArray [4] = 	256'b0;
		MemArray [5] = 	256'b0;
//		MemArray [6] = 	256'b0;  // C register ALU result
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

		
