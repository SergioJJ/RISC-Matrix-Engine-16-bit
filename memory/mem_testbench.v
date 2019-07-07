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

