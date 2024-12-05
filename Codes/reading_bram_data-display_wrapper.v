`timescale 1 ps / 1 ps

module reading_bramdata_display_wrapper
   (AN_0,
    CLK_0,
    CLK_1,
    class_out_0,
    clk_2,
    clk_3,
    clka_0,
    seg_0);
  output [7:0]AN_0;
  input CLK_0;
  input CLK_1;
  output class_out_0;
  input clk_2;
  input clk_3;
  input clka_0;
  output [6:0]seg_0;

  wire [7:0]AN_0;
  wire CLK_0;
  wire CLK_1;
  wire class_out_0;
  wire clk_2;
  wire clk_3;
  wire clka_0;
  wire [6:0]seg_0;

  reading_bramdata_display reading_bramdata_display_i
       (.AN_0(AN_0),
        .CLK_0(CLK_0),
        .CLK_1(CLK_1),
        .class_out_0(class_out_0),
        .clk_2(clk_2),
        .clk_3(clk_3),
        .clka_0(clka_0),
        .seg_0(seg_0));
endmodule
