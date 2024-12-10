`timescale 1ns / 1ps

module dec_segments(
input clk,
input [15:0]F,
input  [3:0]Q,
//input  class_in,
output reg [7:0]AN,
output reg [6:0]seg
    );
  // wire [3:0]gray;
 // assign gray ={bin[3],bin[3]^bin[2],bin[2]^bin[1],bin[1]^bin[0]} ;
 wire [3:0]A,B,C,D;
 wire [3:0]R=0;
 //wire [3:0]Q;
 assign A=F[15:12];
 assign B=F[11:8];  
 assign C=F[7:4];
 assign D=F[3:0];
 
integer count = 0;
reg sclkt = 0;
always@(posedge clk)
begin
    if(count < 499)
    count <= count + 1;
    else
    begin
    count  <= 0;
    sclkt  <= ~sclkt;
    end
end


parameter idle=0,s1=1,s2=2,s3=3,s4=4,s5=5,s6=6,s7=7,s8=8;
reg [3:0] state=idle;
reg  [3:0]temp;

always @ (posedge sclkt)
begin
case(state)
    idle: begin
        AN<=8'b11111111;
        temp<=0;
        state<=s1;
         end
    s1:
        begin
            AN<=8'b11111110;
            temp<=D;
            state<=s2;
        end
    s2:
        begin
            AN<=8'b11111101;
            temp<=C;
            state<=s3; end
    s3:
        begin
            AN<=8'b11111011;
            temp<=B;
            state<=s4;
        end        
    s4:
        begin
            AN<=8'b11110111;
            temp<=A;
            state<=s5;
        end     
    s5:
        begin
            AN<=8'b11101111;
            temp<=Q;
            state<=s6; 
        end       
     s6:
        begin
            AN<=8'b11011111;
            temp<=R;
            state<=s7;
        end 
     s7:
        begin
            AN<=8'b10111111;
            temp<=R;
            state<=s8;
        end  
        s8:
                begin
                    
                    AN<=8'b01111111;
                    temp<=R;
                    state<=idle; 
                end    
             
   default: state<=idle;
 
endcase
end



//always block for converting bcd digit into 7 segment format
    always @(temp)
    begin
        case (temp) //case statement
           0: seg = 7'b0000001;
           
           1: seg = 7'b1001111;
           
           2: seg = 7'b0010010;
           
           3: seg=  7'b0000110;
           
           4: seg=  7'b1001100;
           
           5: seg=  7'b0100100;
           
           6: seg=  7'b0100000;
           
           7: seg = 7'b0001111;
           
           8: seg=  7'b0000000;
           
           9: seg = 7'b0000100;
           
           'ha: seg= 7'b0001000;
           
           'hB: seg= 7'b1100000;
           
           'hC: seg= 7'b0110001;
           
           'hD: seg= 7'b1000010;
           
           'hE: seg= 7'b0110000;
           
           'hF: seg= 7'b0111000;
           
            default : seg = 7'b1111111; 
        endcase
    end
    
endmodule