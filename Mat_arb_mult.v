module Mat_arb_mult(
  clk,
  reset,
  A,
  B,
  Res);

  parameter WIDTH = 8;
  // input ports
  input[4*WIDTH-1:0] A;
  input[4*WIDTH-1:0] B;
  input clk, reset;
  // output ports
  output[63:0] Res;

  //internal variables
  reg[WIDTH-1:0] A1 [0:1][0:1];
  reg[WIDTH-1:0] B1 [0:1][0:1];
  wire[15:0] product [0:1][0:1][0:1];
  wire[15:0] Res1 [0:1][0:1];
  wire[63:0] Res;



  always @ * begin
  //Initialize the matrices-convert 1 D to 3D arrays
    {A1[0][0],A1[0][1],A1[1][0],A1[1][1]} = {A[4*WIDTH-1:3*WIDTH], A[3*WIDTH-1:2*WIDTH], A[2*WIDTH-1:WIDTH], A[WIDTH-1:0]};
 // {A1[0][0],A1[0][1],A1[1][0],A1[1][1]} = {8'd1, 8'd2, 8'd3, 8'd4};
    {B1[0][0],B1[0][1],B1[1][0],B1[1][1]} = {B[4*WIDTH-1:3*WIDTH], B[3*WIDTH-1:2*WIDTH], B[2*WIDTH-1:WIDTH], B[WIDTH-1:0]};
    //{B1[0][0],B1[0][1],B1[1][0],B1[1][1]} = {8'd1, 8'd2, 8'd3, 8'd4};
  end

  genvar i, j, k;
  // parallal multipliers
  for(i=0;i < 2;i=i+1)
    for(j=0;j < 2;j=j+1) begin
        for(k=0;k < 2;k=k+1) begin
          p_multiplier m1(clk, enable, reset, A1[i][k], B1[k][j], product[i][j][k]);
        end
        //  adder a1(product[i][j][k], Res1[i][j], Res1[i][j]);
        assign Res1[i][j] = product[i][j][0] + product[i][j][1] + product[i][j][2] + product[i][j][3];
    end
  // multiplier tree

  assign Res = {Res1[0][0],Res1[0][1],Res1[1][0],Res1[1][1]};
endmodule
