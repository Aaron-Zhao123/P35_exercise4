module Large_Matrix_Mult(
  clk,
  reset,
  Res,
  rdata,
  read_en,
  write_en,
  write_ready
  );

  parameter WIDTH = 8;
  parameter NUM_ELEMENTS = 4;
  parameter MATRIX_WIDTH = 4;
  // input ports
  input[NUM_ELEMENTS*WIDTH-1:0] rdata;
  input clk, reset;
  input read_en, write_en;
  // output ports
  output[NUM_ELEMENTS*WIDTH-1:0] Res;
  output write_ready;

  //internal variables
  reg[WIDTH-1:0] A1 [0:MATRIX_WIDTH-1][0:MATRIX_WIDTH-1];
  reg[WIDTH-1:0] B1 [0:MATRIX_WIDTH-1][0:MATRIX_WIDTH-1];
  reg[NUM_ELEMENTS*WIDTH-1:0] wdata;
  wire[2*WIDTH-1:0] product [0:MATRIX_WIDTH-1][0:MATRIX_WIDTH-1][0:MATRIX_WIDTH-1];
  wire[2*WIDTH-1:0] Res1 [0:MATRIX_WIDTH-1][0:MATRIX_WIDTH-1];
  wire output_ready[0:MATRIX_WIDTH-1][0:MATRIX_WIDTH-1][0:MATRIX_WIDTH-1];

  reg[MATRIX_WIDTH*MATRIX_WIDTH-1:0] element_cnt;
  reg[MATRIX_WIDTH-1:0] row_cnt, col_cnt;
  reg[MATRIX_WIDTH-1:0] o_row_cnt, o_col_cnt;
  reg input_ready, write_ready;
  reg mem_not_full;
  reg out_mem_not_empty;

  integer m;
  integer n;

  initial begin
    element_cnt <= 0;
    row_cnt = 0;
    col_cnt = 0;
    for(m=0;m < MATRIX_WIDTH;m=m+1) begin
      for(n=0;n < MATRIX_WIDTH;n=n+1) begin
        A1[m][n] = 0;
        B1[m][n] = 0;
      end
    end
    input_ready <= 0;
    mem_not_full <= 1;
  end
  // load to mem
  always @(posedge clk) begin
    if (reset == 1'b1) begin
      element_cnt <= 0;
      row_cnt = 0;
      col_cnt = 0;
      for(m=0;m < MATRIX_WIDTH;m=m+1) begin
        for(n=0;n < MATRIX_WIDTH;n=n+1) begin
          A1[m][n] = 0;
          B1[m][n] = 0;
        end
      end
      input_ready <= 0;
      mem_not_full <= 1;
    end
    else begin
      if(read_en == 1'b1 && mem_not_full == 1'b1) begin
        element_cnt <= element_cnt + 1'b1;
        // this row count will overflow
        //add two because 4 datas are read in everytime, 2 for A and 2 for B
        {A1[row_cnt][col_cnt], A1[row_cnt+1][col_cnt],B1[row_cnt][col_cnt],B1[row_cnt+1][col_cnt]} = rdata;
        row_cnt = row_cnt + 2'd2;
        if (row_cnt == MATRIX_WIDTH && col_cnt != MATRIX_WIDTH) begin
          col_cnt = col_cnt + 1'b1;
          row_cnt = 0;
        end
        if ( row_cnt == MATRIX_WIDTH && col_cnt == MATRIX_WIDTH ) begin
          input_ready <= 1;
          mem_not_full <= 0;
        end
        else begin
          input_ready <= 0;
          mem_not_full <= 1;
        end
      end
    end
  end

  genvar i, j, k;
  // parallal multipliers
  for(i=0;i < MATRIX_WIDTH;i=i+1) begin
    for(j=0;j < MATRIX_WIDTH;j=j+1) begin
        for(k=0;k < MATRIX_WIDTH;k=k+1) begin
          p_multiplier m1(clk, input_ready, output_ready[i][j][k], reset, A1[i][k], B1[k][j], product[i][j][k]);
        end
        // adder tree
        assign Res1[i][j] = product[i][j][0] + product[i][j][1] + product[i][j][2] + product[i][j][3];
    end
  end

  // assign Res = {Res1[0][0],Res1[0][1],Res1[1][0],Res1[1][1]};
  initial begin
    o_col_cnt <= 0;
    o_row_cnt <= 0;
    write_ready <= 0;
    wdata <= 0;
    out_mem_not_empty <= 1;
  end
  always @ (posedge clk) begin
    if (reset) begin
      o_col_cnt <= 0;
      o_row_cnt <= 0;
      write_ready <= 0;
      wdata <= 0;
      out_mem_not_empty <= 1;
    end
    if (write_en && output_ready[0][0][0] && out_mem_not_empty) begin
      wdata <= {Res1[o_row_cnt][o_col_cnt], Res1[o_row_cnt+1][o_col_cnt],Res1[o_row_cnt+2][o_col_cnt],Res1[o_row_cnt+3][o_col_cnt]};
      o_col_cnt <= o_col_cnt + 1;
      write_ready <= 1;
      if (o_col_cnt == MATRIX_WIDTH) begin
        write_ready <= 0;
        out_mem_not_empty <= 0;
      end
    end
  end
  assign Res=wdata;
endmodule
