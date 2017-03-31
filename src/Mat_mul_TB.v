module Mat_mul_TB();
  parameter WIDTH = 8;
  reg[WIDTH-1:0] A;
  reg[WIDTH-1:0] B;
  reg clk, reset;
  reg async_reset;
  wire[63:0] Res;

  Mat_mult mm(
    clk, reset, A, B, Res
    );

  initial begin
//    $dumpfile("graycounter.vcd");
//    $dumpvars;
    reset = 0;
    clk = 0;
    A = 8'd1;
    B = 8'd2;
    while (1) begin
      #5 clk = ~ clk;
    end
  end
  
  always @ (negedge clk) begin
    async_reset <= 0;
  end

  initial
   #100 $finish;

endmodule
