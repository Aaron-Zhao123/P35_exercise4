`timescale 1ns/1ps
module Large_Matrix_mult_tb();

  parameter WIDTH = 8;
  parameter NUM_ELEMENTS = 4;
  parameter MATRIX_WIDTH = 4;

  reg clk, reset;
  reg read_en, write_en;
  reg[NUM_ELEMENTS*WIDTH-1:0] rdata;
  wire[NUM_ELEMENTS*WIDTH-1:0] Res;
  wire write_ready;

  Large_Matrix_Mult lmm(
    clk,
    reset,
    Res,
    rdata,
    read_en,
    write_en,
    write_ready
    );

//    $dumpfile("graycounter.vcd");
//    $dumpvars;
    // A = 8'd1;
    // B = 8'd2;
  initial begin
    reset = 0;
    clk = 0;
    rdata = 1;
    read_en = 1;
    write_en = 1;
    while (1) begin
      #5 clk = ~ clk;
    end
  end

  always @ (negedge clk) begin
    reset <= 0;
  end

  initial
   #300 $finish;

endmodule
