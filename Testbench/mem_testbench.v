// Sergio Jimenez
// Testbench for Memory module
// Imports 2kb memory module created for RISC processor HDL project and 
// tests the read and write functionality to all addresses.
//
// Will generate a clock with a 10 ns period, and will feed data to each 
// memory address, then will attempt to read each memory address to confirm
// the write, and will overwrite one address to confirm data is being stored
// as expected
//

`timescale 1ns/1ns
module memory_testbench;
reg [2:0]    address_select; // 0 to 7
reg [255:0]  dataIN;
reg nEnable, ReadWrite, clk, Reset;
wire [255:0] dataBus;


memory     RAM      (dataBus, address_select, nEnable, ReadWrite, clk, Reset);
result_reg Register (dataBus, address_select, nEnable, ReadWrite, clk, Reset);

// tic toc said the clock
always
begin	
	clk = 0;
	forever
		clk = #5 !clk; // 10 ns period clock
end
assign dataBus = dataIN;
//assign dataBus = (nEnable && ReadWrite) ? dataIN : 256'bz;

initial
begin
	Reset = 0;
	nEnable = 1; // disable memory module at first
	ReadWrite = 0; //will begin with a write 
	address_select = 3'h0;
	dataIN = 256'd_42; 
	//set initial write to 0, address 0
	
	#5 // 5  clk h
	Reset = 1; // initial reset
	
	#5 // 10 clk l
	Reset = 0;
	nEnable = 0;
	//set up to write to address 0, value of 0
	
	#10 // 20 clk l, one cycle
	// write performed
	nEnable = 1;

	#5 // 25 clk h
	nEnable = 0;
	address_select = 3'h1;
	dataIN = 256'd_56;
	// set up to write to address 1, value of 1
	
	#10 // 35 clk h, one cycle
	// write performed
	nEnable = 1;
	
	#5 // 40  clk h
	nEnable = 0;
	address_select = 3'h2;
	dataIN = 255'h2;
	// set up to write to address 2, value of 2
	
	#10 // 50 clk h, one cycle
	// write performed
	nEnable = 1;
	
	
	#5 // 85  clk h
	nEnable = 0;
	address_select = 3'h5;
	dataIN = 255'h5;
	// set up to write to address 5, value of 5
	
	#10 // 95 clk h, one cycle
	// write performed
	nEnable = 1;
	
	#5 // 100 clk h
	nEnable = 0;
	address_select = 3'h7;
	dataIN = 255'd 203;
	// set up to write to address 6, value of 6
	
	
	
	#10 // 110 clk h, one cycle
	// write performed
	nEnable = 1;
	dataIN = 256'h z;
	
	
// finish writing sequence, looking at negedge of clock
// begin reading sequence, looking at posedge of clock
	ReadWrite = 1;
	address_select = 3'h0;
	
	
	#5 //clk l
	nEnable = 0;
	
	#10 //clk l, one cycle
	//read address 0 performed
	address_select = 3'h1;
	// set read for next clock posedge
	
	#10 //clk l, one cycle
	//read address 1 performed
	address_select = 3'h2;
	// set read for next clock posedge
	
	#10 //clk l, one cycle
	//read address 4 performed
	address_select = 3'h5;
	// set read for next clock posedge
	
	#5
	nEnable = 1;
	
	#5
	nEnable = 0;
	//read register performed
	address_select = 3'h7;

	
	#10
	nEnable = 1;

end	
	
initial	
  	$monitor ("Time %t  Reset: %b  nEnable: %b  ReadWrite: %b  CLK: %b  ADD [%h] Data In: %d Data Bus: %d", 
	$stime,  Reset, nEnable, ReadWrite, clk, address_select, dataIN, dataBus);
	
endmodule	//that's it
