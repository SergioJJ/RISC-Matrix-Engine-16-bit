# RISC-Matrix-Engine-16-bit
Verilog HDL code to run a RISC processor

This project was created for a HDL class at Texas State University the summer of 2019. The instructor was Mark Welker.
It was a semester long project where we were tasked with individually creating, simulating, and troubleshooting a 4 x 4 matrix math engine of our own design.
The project requirements included the ability to add, subtract, transpose, scalar or matrix multiply two 4x4 matrices of 16 bit integers. The result must then be stored in memory.

The current math of this engine is actually incorrect due to an error in the multiplication. Also, no overflow detection or accomodation has been set.
The next step for this project includes the correction of this issue, and a Python script that can check the answers of a set operation.
