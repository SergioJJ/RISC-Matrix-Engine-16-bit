// Sergio Jimenez
// ALU module for RISC processor
// initial work for multiplication matrix engine, only mult tested but everything is in there
// Single, 256 bit tristated bus
`timescale 1ns/1ns
module ALU (dataBus, op_code, ALU_control, reset, clk, nALU_Enable);
input wire [2:0] op_code, ALU_control;
input wire reset, clk, nALU_Enable;
inout [255:0] dataBus;

reg outEnable;
reg [15:0] MemArray   [3:0][3:0]; // unpack
reg [15:0] A_register [3:0][3:0]; // A input register
reg [15:0] B_register [3:0][3:0]; // B input register
reg [15:0] C_register [3:0][3:0]; // C result register
reg [255:0] outArray; // repack

parameter NO_OP     = 3'b 000;
parameter LOAD      = 3'b 001;
parameter ADD       = 3'b 010;
parameter SUB       = 3'b 011;
parameter SCAL_MUL  = 3'b 100;
parameter MATR_MUL  = 3'b 101;
parameter TRANSPOSE = 3'b 110;
parameter STOP      = 3'b 111; 

//assign outEnable = (ADD | SUB | SCAL_MUL | MATR_MUL | TRANSPOSE );

assign dataBus = (!nALU_Enable && outEnable == 1 && ALU_control == 3'b 111) ? outArray : 256'bz;

always @ (posedge reset) begin
	C_register [0][0] = 0;
	C_register [0][1] = 0;
	C_register [0][2] = 0;
	C_register [0][3] = 0;
	C_register [1][0] = 0;
	C_register [1][1] = 0;
	C_register [1][2] = 0;
	C_register [1][3] = 0;
	C_register [2][0] = 0;
	C_register [2][1] = 0;
	C_register [2][2] = 0;
	C_register [2][3] = 0;
	C_register [3][0] = 0;
	C_register [3][1] = 0;
	C_register [3][2] = 0;
	C_register [3][3] = 0;
	end


always @ (posedge clk)
begin
	
	if (nALU_Enable == 0) begin
	case (op_code)
	NO_OP: begin
	// somehow this does nothing
	outEnable = 0;
	end
	
	LOAD: begin
	//unpack
	MemArray [0][0] = dataBus [255:240]; 
	MemArray [0][1] = dataBus [239:224];
	MemArray [0][2] = dataBus [223:208];
	MemArray [0][3] = dataBus [207:192];
	MemArray [1][0] = dataBus [191:176];
	MemArray [1][1] = dataBus [175:160];
	MemArray [1][2] = dataBus [159:144];
	MemArray [1][3] = dataBus [143:128];
	MemArray [2][0] = dataBus [127:112];
	MemArray [2][1] = dataBus [111: 96];
	MemArray [2][2] = dataBus [95 : 80];
	MemArray [2][3] = dataBus [79 : 64];
	MemArray [3][0] = dataBus [63 : 48];
	MemArray [3][1] = dataBus [47 : 32];
	MemArray [3][2] = dataBus [31 : 16];
	MemArray [3][3] = dataBus [15 :  0];
	outEnable = 0;
	
	
	if (ALU_control == 3'b 001) begin// load A
	
	A_register [0][0] = MemArray [0][0];
	A_register [0][1] = MemArray [0][1];
	A_register [0][2] = MemArray [0][2];
	A_register [0][3] = MemArray [0][3];
	A_register [1][0] = MemArray [1][0];
	A_register [1][1] = MemArray [1][1];
	A_register [1][2] = MemArray [1][2];
	A_register [1][3] = MemArray [1][3];
	A_register [2][0] = MemArray [2][0];
	A_register [2][1] = MemArray [2][1];
	A_register [2][2] = MemArray [2][2];
	A_register [2][3] = MemArray [2][3];
	A_register [3][0] = MemArray [3][0];
	A_register [3][1] = MemArray [3][1];
	A_register [3][2] = MemArray [3][2];
	A_register [3][3] = MemArray [3][3];
	
	end
	
	else if (ALU_control == 3'b 100) begin// load B
	B_register [0][0] = MemArray [0][0];
	B_register [0][1] = MemArray [0][1];
	B_register [0][2] = MemArray [0][2];
	B_register [0][3] = MemArray [0][3];
	B_register [1][0] = MemArray [1][0];
	B_register [1][1] = MemArray [1][1];
	B_register [1][2] = MemArray [1][2];
	B_register [1][3] = MemArray [1][3];
	B_register [2][0] = MemArray [2][0];
	B_register [2][1] = MemArray [2][1];
	B_register [2][2] = MemArray [2][2];
	B_register [2][3] = MemArray [2][3];
	B_register [3][0] = MemArray [3][0];
	B_register [3][1] = MemArray [3][1];
	B_register [3][2] = MemArray [3][2];
	B_register [3][3] = MemArray [3][3];

	end
	
	else if (ALU_control == 3'b 010) begin// transfer from C result to A input
	A_register [0][0] = C_register [0][0];
	A_register [0][1] = C_register [0][1];
	A_register [0][2] = C_register [0][2];
	A_register [0][3] = C_register [0][3];
	A_register [1][0] = C_register [1][0];
	A_register [1][1] = C_register [1][1];
	A_register [1][2] = C_register [1][2];
	A_register [1][3] = C_register [1][3];
	A_register [2][0] = C_register [2][0];
	A_register [2][1] = C_register [2][1];
	A_register [2][2] = C_register [2][2];
	A_register [2][3] = C_register [2][3];
	A_register [3][0] = C_register [3][0];
	A_register [3][1] = C_register [3][1];
	A_register [3][2] = C_register [3][2];
	A_register [3][3] = C_register [3][3];
	
	end


	end // end LOAD case
	

	ADD: begin
	C_register [0][0] = A_register [0][0] + B_register [0][0];
	C_register [0][1] = A_register [0][1] + B_register [0][1];
	C_register [0][2] = A_register [0][2] + B_register [0][2];
	C_register [0][3] = A_register [0][3] + B_register [0][3];
	C_register [1][0] = A_register [1][0] + B_register [1][0];
	C_register [1][1] = A_register [1][1] + B_register [1][1];
	C_register [1][2] = A_register [1][2] + B_register [1][2];
	C_register [1][3] = A_register [1][3] + B_register [1][3];
	C_register [2][0] = A_register [2][0] + B_register [2][0];
	C_register [2][1] = A_register [2][1] + B_register [2][1];
	C_register [2][2] = A_register [2][2] + B_register [2][2];
	C_register [2][3] = A_register [2][3] + B_register [2][3];
	C_register [3][0] = A_register [3][0] + B_register [3][0];
	C_register [3][1] = A_register [3][1] + B_register [3][1];
	C_register [3][2] = A_register [3][2] + B_register [3][2];
	C_register [3][3] = A_register [3][3] + B_register [3][3];
	outEnable = 1;
	end
	
	SUB: begin
	C_register [0][0] = A_register [0][0] - B_register [0][0];
	C_register [0][1] = A_register [0][1] - B_register [0][1];
	C_register [0][2] = A_register [0][2] - B_register [0][2];
	C_register [0][3] = A_register [0][3] - B_register [0][3];
	C_register [1][0] = A_register [1][0] - B_register [1][0];
	C_register [1][1] = A_register [1][1] - B_register [1][1];
	C_register [1][2] = A_register [1][2] - B_register [1][2];
	C_register [1][3] = A_register [1][3] - B_register [1][3];
	C_register [2][0] = A_register [2][0] - B_register [2][0];
	C_register [2][1] = A_register [2][1] - B_register [2][1];
	C_register [2][2] = A_register [2][2] - B_register [2][2];
	C_register [2][3] = A_register [2][3] - B_register [2][3];
	C_register [3][0] = A_register [3][0] - B_register [3][0];
	C_register [3][1] = A_register [3][1] - B_register [3][1];
	C_register [3][2] = A_register [3][2] - B_register [3][2];
	C_register [3][3] = A_register [3][3] - B_register [3][3];
	outEnable = 1;
	end

	
	SCAL_MUL: begin // just doing a subtract for now, will replace with proper scale multiply later
	// set B register to an identity matrix
	B_register [0][0] = 16'h 1;
	B_register [0][1] = 16'h 0;
	B_register [0][2] = 16'h 0;
	B_register [0][3] = 16'h 0;
	B_register [1][0] = 16'h 0;
	B_register [1][1] = 16'h 1;
	B_register [1][2] = 16'h 0;
	B_register [1][3] = 16'h 0;
	B_register [2][0] = 16'h 0;
	B_register [2][1] = 16'h 0;
	B_register [2][2] = 16'h 1;
	B_register [2][3] = 16'h 0;
	B_register [3][0] = 16'h 0;
	B_register [3][1] = 16'h 0;
	B_register [3][2] = 16'h 0;
	B_register [3][3] = 16'h 1;
	
	
	
	C_register [0][0] = (A_register [0][0] * B_register [0][0]) + (A_register [0][1] * B_register [1][0]) + (A_register [0][2] * B_register [2][0]) + (A_register [0][3] * B_register [3][0]);
	C_register [0][1] = (A_register [0][0] * B_register [0][1]) + (A_register [0][1] * B_register [1][1]) + (A_register [0][2] * B_register [2][1]) + (A_register [0][3] * B_register [3][1]);
	C_register [0][2] = (A_register [0][0] * B_register [0][2]) + (A_register [0][1] * B_register [1][2]) + (A_register [0][2] * B_register [2][2]) + (A_register [0][3] * B_register [3][2]);
	C_register [0][3] = (A_register [0][0] * B_register [0][3]) + (A_register [0][1] * B_register [1][3]) + (A_register [0][2] * B_register [2][3]) + (A_register [0][3] * B_register [3][3]);


	C_register [1][0] = (A_register [1][0] * B_register [0][0]) + (A_register [1][1] * B_register [1][0]) + (A_register [1][2] * B_register [2][0]) + (A_register [1][3] * B_register [3][0]);
	C_register [1][1] = (A_register [1][0] * B_register [0][1]) + (A_register [1][1] * B_register [1][1]) + (A_register [1][2] * B_register [2][1]) + (A_register [1][3] * B_register [3][1]);
	C_register [1][2] = (A_register [1][0] * B_register [0][2]) + (A_register [1][1] * B_register [1][2]) + (A_register [1][2] * B_register [2][2]) + (A_register [1][3] * B_register [3][2]);
	C_register [1][3] = (A_register [1][0] * B_register [0][3]) + (A_register [1][1] * B_register [1][3]) + (A_register [1][2] * B_register [2][3]) + (A_register [1][3] * B_register [3][3]);


	C_register [2][0] = (A_register [2][0] * B_register [0][0]) + (A_register [2][1] * B_register [1][0]) + (A_register [2][2] * B_register [2][0]) + (A_register [2][3] * B_register [3][0]);
	C_register [2][1] = (A_register [2][0] * B_register [0][1]) + (A_register [2][1] * B_register [1][1]) + (A_register [2][2] * B_register [2][1]) + (A_register [2][3] * B_register [3][1]);
	C_register [2][2] = (A_register [2][0] * B_register [0][2]) + (A_register [2][1] * B_register [1][2]) + (A_register [2][2] * B_register [2][2]) + (A_register [2][3] * B_register [3][2]);
	C_register [2][3] = (A_register [2][0] * B_register [0][3]) + (A_register [2][1] * B_register [1][3]) + (A_register [2][2] * B_register [2][3]) + (A_register [2][3] * B_register [3][3]);


	C_register [3][0] = (A_register [3][0] * B_register [0][0]) + (A_register [3][1] * B_register [1][0]) + (A_register [3][2] * B_register [2][0]) + (A_register [3][3] * B_register [3][0]);
	C_register [3][1] = (A_register [3][0] * B_register [0][1]) + (A_register [3][1] * B_register [1][1]) + (A_register [3][2] * B_register [2][1]) + (A_register [3][3] * B_register [3][1]);
	C_register [3][2] = (A_register [3][0] * B_register [0][2]) + (A_register [3][1] * B_register [1][2]) + (A_register [3][2] * B_register [2][2]) + (A_register [3][3] * B_register [3][2]);
	C_register [3][3] = (A_register [3][0] * B_register [0][3]) + (A_register [3][1] * B_register [1][3]) + (A_register [3][2] * B_register [2][3]) + (A_register [3][3] * B_register [3][3]); 
	
	outEnable = 1;
	end
	
	MATR_MUL: begin

	C_register [0][0] = (A_register [0][0] * B_register [0][0]) + (A_register [0][1] * B_register [1][0]) + (A_register [0][2] * B_register [2][0]) + (A_register [0][3] * B_register [3][0]);
	C_register [0][1] = (A_register [0][0] * B_register [0][1]) + (A_register [0][1] * B_register [1][1]) + (A_register [0][2] * B_register [2][1]) + (A_register [0][3] * B_register [3][1]);
	C_register [0][2] = (A_register [0][0] * B_register [0][2]) + (A_register [0][1] * B_register [1][2]) + (A_register [0][2] * B_register [2][2]) + (A_register [0][3] * B_register [3][2]);
	C_register [0][3] = (A_register [0][0] * B_register [0][3]) + (A_register [0][1] * B_register [1][3]) + (A_register [0][2] * B_register [2][3]) + (A_register [0][3] * B_register [3][3]);


	C_register [1][0] = (A_register [1][0] * B_register [0][0]) + (A_register [1][1] * B_register [1][0]) + (A_register [1][2] * B_register [2][0]) + (A_register [1][3] * B_register [3][0]);
	C_register [1][1] = (A_register [1][0] * B_register [0][1]) + (A_register [1][1] * B_register [1][1]) + (A_register [1][2] * B_register [2][1]) + (A_register [1][3] * B_register [3][1]);
	C_register [1][2] = (A_register [1][0] * B_register [0][2]) + (A_register [1][1] * B_register [1][2]) + (A_register [1][2] * B_register [2][2]) + (A_register [1][3] * B_register [3][2]);
	C_register [1][3] = (A_register [1][0] * B_register [0][3]) + (A_register [1][1] * B_register [1][3]) + (A_register [1][2] * B_register [2][3]) + (A_register [1][3] * B_register [3][3]);


	C_register [2][0] = (A_register [2][0] * B_register [0][0]) + (A_register [2][1] * B_register [1][0]) + (A_register [2][2] * B_register [2][0]) + (A_register [2][3] * B_register [3][0]);
	C_register [2][1] = (A_register [2][0] * B_register [0][1]) + (A_register [2][1] * B_register [1][1]) + (A_register [2][2] * B_register [2][1]) + (A_register [2][3] * B_register [3][1]);
	C_register [2][2] = (A_register [2][0] * B_register [0][2]) + (A_register [2][1] * B_register [1][2]) + (A_register [2][2] * B_register [2][2]) + (A_register [2][3] * B_register [3][2]);
	C_register [2][3] = (A_register [2][0] * B_register [0][3]) + (A_register [2][1] * B_register [1][3]) + (A_register [2][2] * B_register [2][3]) + (A_register [2][3] * B_register [3][3]);


	C_register [3][0] = (A_register [3][0] * B_register [0][0]) + (A_register [3][1] * B_register [1][0]) + (A_register [3][2] * B_register [2][0]) + (A_register [3][3] * B_register [3][0]);
	C_register [3][1] = (A_register [3][0] * B_register [0][1]) + (A_register [3][1] * B_register [1][1]) + (A_register [3][2] * B_register [2][1]) + (A_register [3][3] * B_register [3][1]);
	C_register [3][2] = (A_register [3][0] * B_register [0][2]) + (A_register [3][1] * B_register [1][2]) + (A_register [3][2] * B_register [2][2]) + (A_register [3][3] * B_register [3][2]);
	C_register [3][3] = (A_register [3][0] * B_register [0][3]) + (A_register [3][1] * B_register [1][3]) + (A_register [3][2] * B_register [2][3]) + (A_register [3][3] * B_register [3][3]); 
	
	outEnable = 1;
	end
	
	TRANSPOSE: begin
	
	C_register [0][0] = A_register [0][0];
	C_register [0][1] = A_register [1][0];
	C_register [0][2] = A_register [2][0];
	C_register [0][3] = A_register [3][0];
	C_register [1][0] = A_register [0][1];
	C_register [1][1] = A_register [1][1];
	C_register [1][2] = A_register [2][1];
	C_register [1][3] = A_register [3][1];
	C_register [2][0] = A_register [0][2];
	C_register [2][1] = A_register [1][2];
	C_register [2][2] = A_register [2][2];
	C_register [2][3] = A_register [3][2];
	C_register [3][0] = A_register [0][3];
	C_register [3][1] = A_register [1][3];
	C_register [3][2] = A_register [2][3];
	C_register [3][3] = A_register [3][3];
	outEnable = 1;
	
	end
	
	STOP: begin
	outEnable = 0;
	end
	endcase
	
	if (ALU_control == 3'b 111) begin// spit out on the databus, aka repack and drives bus
	
	outArray [255:240] = C_register [0][0];
	outArray [239:224] = C_register [0][1];
	outArray [223:208] = C_register [0][2];
	outArray [207:192] = C_register [0][3];
	outArray [191:176] = C_register [1][0];
	outArray [175:160] = C_register [1][1];
	outArray [159:144] = C_register [1][2];
	outArray [143:128] = C_register [1][3];
	outArray [127:112] = C_register [2][0];
	outArray [111: 96] = C_register [2][1];
	outArray [95 : 80] = C_register [2][2];
	outArray [79 : 64] = C_register [2][3];
	outArray [63 : 48] = C_register [3][0];
	outArray [47 : 32] = C_register [3][1];
	outArray [31 : 16] = C_register [3][2];
	outArray [15 :  0] = C_register [3][3];
	
	end
	
	end // end if
end
endmodule
