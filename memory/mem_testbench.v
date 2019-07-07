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
reg address_select [7:0];
reg dataIN [255:0];
reg nEnable, ReadWrite, clk, reset;
wire dataBus [255:0];
  

memory RAM (dataBus, address_select, nEnable, ReadWrite, clk, Reset);

// tic toc said the clock
initial
begin	
	clk = 0;
	always
		clk = #5 !clk; // 10 ns period clock
end


initial
begin
	reset = 0;
	nEnable = 1; // disable memory module at first
	ReadWrite = 0; //will begin with a write 
	address_select = 3'b0;
	dataIn = 255'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000; 
	//set initial write to 0, address 0
	
	#5 // clk h
	reset = 1; // initial reset
	
	#5 // clk l
	reset = 0;
	nEnable = 0;
	//set up to write to address 0, value of 0
	
	#10 // clk l, one cycle
	// write performed
	nEnable = 1;

	#5 // clk h
	nEnable = 0;
	address_select = 3'b1;
	dataIn = 255'h1;
	// set up to write to address 1, value of 1
	
	#10 // clk h, one cycle
	// write performed
	nEnable = 1;
	
	#5 // clk h
	nEnable = 0;
	address_select = 3'b2;
	dataIn = 255'h2;
	// set up to write to address 2, value of 2
	
	#10 // clk h, one cycle
	// write performed
	nEnable = 1;
	
	#5 // clk h
	nEnable = 0;
	address_select = 3'b3;
	dataIn = 255'h3;
	// set up to write to address 3, value of 3
	
	#10 // clk h, one cycle
	// write performed
	nEnable = 1;
	
	#5 // clk h
	nEnable = 0;
	address_select = 3'b4;
	dataIn = 255'h4;
	// set up to write to address 4, value of 4
	
	#10 // clk h, one cycle
	// write performed
	nEnable = 1;
	
	#5 // clk h
	nEnable = 0;
	address_select = 3'b5;
	dataIn = 255'h5;
	// set up to write to address 5, value of 5
	
	#10 // clk h, one cycle
	// write performed
	nEnable = 1;
	
	#5 // clk h
	nEnable = 0;
	address_select = 3'b6;
	dataIn = 255'h6;
	// set up to write to address 6, value of 6
	
	#10 // clk h, one cycle
	// write performed
	nEnable = 1;
		
	#5 // clk h
	nEnable = 0;
	address_select = 3'b7;
	dataIn = 255'h7;
	// set up to write to address 7, value of 7
	
	#10 // clk h, one cycle
	// write performed
	nEnable = 1;
	
// finish writing sequence, looking at negedge of clock
// begin reading sequence, looking at posedge of clock
	ReadWrite = 1;
	address_select = 3'b0;
	
	#5 //clk l
	nEnable = 0;
	
	#10 //clk l, one cycle
	//read address 0 performed
	address_select = 3'b1;
	// set read for next clock posedge
	
	#10 //clk l, one cycle
	//read address 1 performed
	address_select = 3'b2;
	// set read for next clock posedge
	
	
	#10 //clk l, one cycle
	//read address 2 performed
	address_select = 3'b3;
	// set read for next clock posedge
	
	
	#10 //clk l, one cycle
	//read address 3 performed
	address_select = 3'b4;
	// set read for next clock posedge
	
	#10 //clk l, one cycle
	//read address 4 performed
	address_select = 3'b5;
	// set read for next clock posedge
	
	
	#10 //clk l, one cycle
	//read address 5 performed
	address_select = 3'b6;
	// set read for next clock posedge
	
	
	#10 //clk l, one cycle
	//read address 6 performed
	address_select = 3'b7;
	// set read for next clock posedge
	
	
	#10 //clk l, one cycle
	//read address 7 performed
	
	// Will now do one write into address on of another value memory can be overwritten
	#5 // clk h
	
	address_select = 3'b1;
	dataIN = 256'b
	
	
	
	
	
	
	
	$monitor ("Time %t  Reset: %b  nEnable: %b  ReadWrite: %b  CLK: %b  ADD [%h] Data In: %d Data Bus: %d",
			  stime,  Reset, nEnable, ReadWrite, clk, address_select, dataIN, dataBus);
	
end
endmodule	//that's it
