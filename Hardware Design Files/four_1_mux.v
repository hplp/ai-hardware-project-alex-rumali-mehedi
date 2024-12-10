`timescale 1ns / 1ps
module m4(
input [15:0] a,  
input [14:0] b,
input [9:0] c,
input [12:0] d,
input [1:0] sel,
output [15:0]P
);

assign P = sel[1] ? (sel[0]? d: c): (sel[0] ? b: a);
endmodule