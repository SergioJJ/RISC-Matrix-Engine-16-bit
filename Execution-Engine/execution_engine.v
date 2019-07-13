// Sergio Jimenez
// Execution Engine
// Takes in 3 bit Opcodes and decodes info that controls outside modules that the opcodes refer to.
// Simplified one bit select actions will be used for this assignment. More complex state output will be
// nescessary when implementing into 
// OPCODES
// 000 NO-OP
// 001 LOAD
// 010 ADD
// 011 SUB
// 100 SCAL MUL
// 101 MATR MUL
// 110 TRANSPOSE
// 111 STOP
// 
// 
`timescale 1ns/1ns
module execution_engine ();
