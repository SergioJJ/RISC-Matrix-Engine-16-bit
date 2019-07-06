// Sergio Jimmenez
// 8 address 256 bit memory
// This module will utilize a single 256 bit I/O Bus which will be tristated when not in use.
// 
// 
// Route data to/from memory array as per ReadWrite bit
// ReadWrite 1 = Read; at risingedge
// ReadWrite 0 = Write at falling edge
// nEnable is active low
// http://www.asic-world.com/examples/verilog/ram_sp_sr_sw.html



module memory (dataBus, address, nEnable, ReadWrite, clk);

input	ReadWrite, nEnable, clk;
input	[3:0] address;

inout 	[255:0] dataBus; // single I/O 256 bit tristated bus

reg [255:0] MemArray[0:7]; // creates 8, 256 bit arrays for use as memory
wire [255:0] inputArray;

assign dataBus = (!nEnable) ? inputArray : 256'bz;
assign inputArray = dataBus;


always @ (posedge clk)
begin
	if (ReadWrite)	
		MemArray[address] = inputArray;  // performs a read
			
	else dataBus = MemArray[address]; // performs a write
end


endmodule
