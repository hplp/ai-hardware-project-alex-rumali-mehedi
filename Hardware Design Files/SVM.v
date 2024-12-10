`timescale 1ns / 1ps
module classifier_svm(clk,f1,f2,f3,f4,class_out);
input [15:0] f1;
input [14:0] f2;
input [9:0] f3;
input [12:0] f4;
input clk;
wire signed[23:0]result;
wire signed[26:0] P1;
wire signed[25:0] P2;
wire signed[20:0] P3;
wire signed[23:0] P4;
output class_out;

wire signed[26:0]s1;
wire signed[26:0]s2;
wire signed[26:0]s3;
wire signed[23:0]s4;



parameter signed W1=-10'd37;
parameter signed W2=-10'd1;
parameter signed W3=-10'd233;
parameter signed W4=-10'd423;
//parameter signed B=22'd16384; 
parameter signed B=22'd131072; 



multi #(16,9,26) m1 ({0,f1},W1,P1);
multi #(15,9,25) m2 ({0,f2},W2,P2);
multi #(10,9,20) m3({0,f3},W3,P3);
multi #(13,9,23) m4({0,f4},W4,P4);



adder #(26,25,26) ad1 (P1,P2,s1);
adder #(26,20,26) ad2 (s1,P3,s2);
adder #(26,23,26) ad3 (s2,P4,s3);

reg signed [23:0] s3_reg;

always @ (posedge clk) s3_reg <= s3;

adder #(23,21,23) ad4(s3_reg,B,s4);

assign result=s4;

comparator c1(result,class_out);

reg class_reg;

always @ (posedge clk) class_reg <= class_out;

endmodule

//////////////////Comparator Module////////////////////////////////

module comparator(x,class);
input signed [23:0]x;
output reg class=0;
wire  a1;
assign a1=x[23];
always @(a1) begin
if(a1==0) begin
class<=1;
end
else begin
class<=0;
end
end
endmodule

//////////////////Multipler Module////////////////////////////////

module multi #(parameter in1=17,parameter in2=17, parameter ot=34)(a, b, p);
  input signed [in1:0] a;
  input signed [in2:0] b;
  output signed [ot:0] p;
  assign p=a*b; 
endmodule


/////////////////Adder Module//////////////////////////////

module adder #(parameter in1=17,parameter in2=17, parameter ot=17)(x,y,sum);
input signed[in1:0] x;
input signed[in2:0] y;
output signed[ot:0] sum;
assign sum=x+y;
endmodule
