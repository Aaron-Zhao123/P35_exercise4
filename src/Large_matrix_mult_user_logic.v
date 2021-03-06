module Large_Matrix_Mult(
  w_clk,
  r_clk,
  w_reset,
  r_reset,
  Res,
  wdata,
  w_en,
  r_en,
  w_ready,
  r_ready
  );

  parameter WIDTH = 8;
  parameter NUM_ELEMENTS = 4;
  parameter MATRIX_WIDTH = 4;
  // input ports
  input[NUM_ELEMENTS*WIDTH-1:0] wdata;
  input w_clk, r_clk, w_reset, r_reset;
  input w_en, r_en;
  // output ports
  output[NUM_ELEMENTS*WIDTH-1:0] Res;
  output w_ready, r_ready;

  //internal variables
  reg[WIDTH-1:0] A1 [0:MATRIX_WIDTH-1][0:MATRIX_WIDTH-1];
  reg[WIDTH-1:0] B1 [0:MATRIX_WIDTH-1][0:MATRIX_WIDTH-1];
  reg[NUM_ELEMENTS*WIDTH-1:0] rdata;
  wire[2*WIDTH-1:0] product [0:MATRIX_WIDTH-1][0:MATRIX_WIDTH-1][0:MATRIX_WIDTH-1];
  wire[2*WIDTH-1:0] Res1 [0:MATRIX_WIDTH-1][0:MATRIX_WIDTH-1];
  wire output_ready[0:MATRIX_WIDTH-1][0:MATRIX_WIDTH-1][0:MATRIX_WIDTH-1];

  reg[MATRIX_WIDTH*MATRIX_WIDTH-1:0] element_cnt;
  reg[MATRIX_WIDTH-1:0] row_cnt, col_cnt;
  reg[MATRIX_WIDTH-1:0] o_row_cnt, o_col_cnt;
  reg input_ready, r_ready;
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

  assign w_ready = mem_not_full;
  // load to mem
  always @(posedge w_clk) begin
    if (w_reset == 1'b1) begin
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
      if(w_en == 1'b1 && mem_not_full == 1'b1) begin
        element_cnt <= element_cnt + 1'b1;
        // this row count will overflow
        //add two because 4 datas are read in everytime, 2 for A and 2 for B
        {A1[row_cnt][col_cnt], A1[row_cnt+1][col_cnt],B1[row_cnt][col_cnt],B1[row_cnt+1][col_cnt]} = wdata;
        row_cnt = row_cnt + 2'd2;
        if (row_cnt == MATRIX_WIDTH && col_cnt != MATRIX_WIDTH) begin
          col_cnt = col_cnt + 1'b1;
          row_cnt = 0;
        end
        if (row_cnt == MATRIX_WIDTH && col_cnt == MATRIX_WIDTH) begin
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
          p_multiplier m1(w_clk, input_ready, output_ready[i][j][k], w_reset, A1[i][k], B1[k][j], product[i][j][k]);
        end
        // adder tree
        assign Res1[i][j] = product[i][j][0] + product[i][j][1] + product[i][j][2] + product[i][j][3];
    end
  end

  initial begin
    o_col_cnt <= 0;
    o_row_cnt <= 0;
    r_ready <= 0;
    rdata <= 0;
    out_mem_not_empty <= 0;
  end
  // output mem not empty logic
  always @ (posedge r_clk) begin
    if (r_reset) begin
      out_mem_not_empty <= 1;
    end
    else begin
      if (output_ready[0][0][0] && o_col_cnt < MATRIX_WIDTH) begin
        out_mem_not_empty <= 1;
      end
      if (o_col_cnt == MATRIX_WIDTH) begin
        out_mem_not_empty <= 0;
      end
    end
  end

  always @ (posedge r_clk) begin
    if (r_reset) begin
      o_col_cnt <= 0;
      o_row_cnt <= 0;
      r_ready <= 0;
      rdata <= 0;
    end
    if (r_en && out_mem_not_empty) begin
      rdata <= {Res1[o_row_cnt][o_col_cnt], Res1[o_row_cnt+1][o_col_cnt],Res1[o_row_cnt+2][o_col_cnt],Res1[o_row_cnt+3][o_col_cnt]};
      o_col_cnt <= o_col_cnt + 1;
      r_ready <= 1;
      if (o_col_cnt == MATRIX_WIDTH) begin
        rdata <= 0;
        r_ready <= 0;
      end
    end
    else begin
      rdata <= 0;
    end
  end
  assign Res=rdata;
endmodule
