// Sergio Jimenez
// Testbench for main RAM, Result Register and INST memory modules
// An initial write into the memory will take place into a few addresses.
// RAM address 2 will contain instructions in a defined format to be written
// into the INST memory. The INST address will be driven by the
// testbench and will display first few addresses in the INST memory
// while RAM reading and Result Register reading occur simultaneously.

`timescale 1ns/1ns
module all_memory_testbench;
reg [2:0]    address_select; // 0 to 7
//Feeds in data to memory
reg [255:0]  dataIN;

// to select read address in INST module, will be driven by program counter
reg [4:0]    inst_address; 

reg nEnable, ReadWrite, clk, load_instrs, Reset;
// Data bus output
wire [255:0] dataBus;
// INST memory output
wire [11:0] inst_read;

memory     RAM          (dataBus, address_select, nEnable, ReadWrite,   clk, Reset);
result_reg Register     (dataBus, address_select, nEnable, ReadWrite,   clk, Reset);
instruction_memory INST (dataBus, inst_read, inst_address, load_instrs, clk, Reset);

// tic toc said the clock
always
begin	
	clk = 0;
	forever
		clk = #5 !clk; // 10 ns period clock
end
assign dataBus = dataIN;


initial
begin
	Reset          = 0;
	nEnable        = 1; // disable memory module at first
	ReadWrite      = 0; //will begin with a write 
	load_instrs    = 0; // no writing into INST memory yet
	address_select = 3'h0;
	dataIN         = 256'd_42; 
	//set initial write to 0, address 0
	
	#5 // 5  clk h
	Reset = 1; // initial reset
	
	#5 // 10 clk l
	Reset = 0;
	nEnable = 0;
	//set up to write to address 0, value of 0
	
	#10 // 20 clk l, one cycle
	// write performed


	#5 // 25 clk h
	nEnable = 0;
	address_select = 3'h1;
	dataIN = 256'd_56;
	// set up to write to address 1, value of 1
	
	#10 // 35 clk h, one cycle
	// write performed

	
	#5 // 40  clk h
	nEnable = 0;
	address_select = 3'h2;
	dataIN = 256'h_F0D_301_AAA_00f_000_200_0d0_008_000_200_090_009_000_b00_060_007_002_200_040_00c_000_4;
	// set up to write to address 2, value of 2
	
	#10 // 50 clk h, one cycle
	// write performed

	
	
	#5 // 85  clk h
	nEnable = 0;
	address_select = 3'h5;
	dataIN = 256'h5;
	// set up to write to address 5, value of 5
	
	#10 // 95 clk h, one cycle
	// write performed

	
	#5 // 100 clk h
	nEnable = 0;
	address_select = 3'h7;
	dataIN = 256'd 203;
	// set up to write to address 6, value of 6
	
	
	
	#10 // 110 clk h, one cycle
	// write performed
	nEnable = 1;
	dataIN = 256'h z;

	
	
// finish writing sequence, looking at negedge of clock
// begin reading sequence, looking at posedge of clock
// Reading address #3 so we can load in INST memory
	ReadWrite = 1;
	address_select = 3'h2;
	inst_address = 5'h 0;

	#5 //clk l
	nEnable = 0;

	#5
	load_instrs = 1; // will begin reading from INST memory

	
	#5 //clk l, one cycle
	//read address 0 performed
	address_select = 3'h1;
	load_instrs = 0; // finish write into INST memory
	// set read for next clock posedge
	
	#10 //clk l, one cycle
	//read address 1 performed
	address_select = 3'h 0;
	inst_address   = 5'h 1;
	// set read for next clock posedge
	
	#10 //clk l, one cycle
	//read address 4 performed
	address_select = 3'h5;
	inst_address   = 5'h 2;
	// set read for next clock posedge
	
	#5
	nEnable = 1;
	
	#5
	nEnable = 0;
	//read register performed
	address_select = 3'h7;
	inst_address = 5'h 3;
	
	#10
	nEnable = 1;

end	
	
initial	
  	$monitor ("Time %t  Reset: %b  nEnable: %b  ReadWrite: %b  CLK: %b  ADD [%h] Data In: %d Data Bus: %d", 
	$stime,  Reset, nEnable, ReadWrite, clk, address_select, dataIN, dataBus);
	
endmodule	//that's it
