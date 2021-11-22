/*
   fix point complex number add / sub

   ARITH_MODE = 0: ADD
   ARITH_MODE = 1: SUB
   ARITH_MODE = 2:
       arith_mode = 0 : ADD
       arith_mode = 1 : SUB
  
   FLIP: flip opa and opb
      0 : no flip
      1 : flip
      2 : determined by flip pin


   SHIFT_MODE = 0 -> no shifting
   SHIFT_MODE > 0 -> follows fix_shift convention
   
   SAT_PIPE: different stage of pipelined register inserted after sat
   SHIFT_PIPE: different stage of pipelined register inserted after shift
   ADD_PIPE: different stage of pipelined register inserted after add / sub itself
   
   Revisions:
      10/11/21:
        First Documentation
*/

module fix_c_add_sub #(
   parameter IN_WIDTH = 16,
   parameter OUT_WIDTH = 16,
   parameter ARITH_MODE_R = 1,
   parameter ARITH_MODE_I = 1,
   parameter FLIP = 0,
   parameter SHIFT_CONST = 3,
   parameter SHIFT_MODE = 1,
   parameter SAT_PIPE = 1,
   parameter SHIFT_PIPE = 1,
   parameter ADD_PIPE = 1
)
(
   input   [IN_WIDTH - 1 : 0]  opa_R,
   input   [IN_WIDTH - 1 : 0]  opa_I,
   input   [IN_WIDTH - 1 : 0]  opb_R,
   input   [IN_WIDTH - 1 : 0]  opb_I,
   // only useful if ARITH_MODE == 2
   input                       arith_mode_R,
   input                       arith_mode_I,
   // only useful if FLIP == 2
   input                       flip,
   input   [$clog2(IN_WIDTH + 1) - 1 : 0] shift_amount,
   output  logic [OUT_WIDTH - 1 : 0]  out_R,
   output  logic [OUT_WIDTH - 1 : 0]  out_I,
   input                       clk,
   input                       rst_n
);

   fix_add_sub #(
      .IN_WIDTH (IN_WIDTH),
      .OUT_WIDTH (OUT_WIDTH),
      .ARITH_MODE (ARITH_MODE_R),
      .SAT_PIPE (SAT_PIPE),
      .FLIP(FLIP), 
      .ADD_PIPE(ADD_PIPE),
      .SHIFT_CONST(SHIFT_CONST),
      .SHIFT_MODE(SHIFT_MODE),
      .SHIFT_PIPE(SHIFT_PIPE)
   ) fix_add_sub_R
   (
      .opa(opa_R),
      .opb(opb_R),
      .arith_mode(arith_mode_R),
      .flip(flip),
      .shift_amount(shift_amount),
      .out(out_R),
      .*
   );

   fix_add_sub #(
      .IN_WIDTH (IN_WIDTH),
      .OUT_WIDTH (OUT_WIDTH),
      .ARITH_MODE (ARITH_MODE_I),
      .SAT_PIPE (SAT_PIPE),
      .FLIP(FLIP), 
      .ADD_PIPE(ADD_PIPE),
      .SHIFT_CONST(SHIFT_CONST),
      .SHIFT_MODE(SHIFT_MODE),
      .SHIFT_PIPE(SHIFT_PIPE)
   ) fix_add_sub_I
   (
      .opa(opa_I),
      .opb(opb_I),
      .arith_mode(arith_mode_I),
      .flip(flip),
      .shift_amount(shift_amount),
      .out(out_I),
      .*
   );
   

endmodule
