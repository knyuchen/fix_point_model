/*
   fix point complex number mult

   ARITH_MODE = 0: opa * opb
   ARITH_MODE = 1: opa * opb'
   ARITH_MODE = 2:
       arith_mode = 0 : opa * opb
       arith_mode = 1 : opa * opb'
   
*/

module fix_c_mult #(
   parameter IN_WIDTH = 16,
   parameter OUT_WIDTH = 16,
   parameter ARITH_MODE_R = 1,
   parameter ARITH_MODE_I = 1,
   parameter FLIP = 1,
   parameter SHIFT_CONST = 3,
   parameter SHIFT_MODE = 1,
   parameter MULT_PIPE  = 1,
   parameter ADD_PIPE = 1,
   parameter SAT_PIPE = 1,
   parameter SHIFT_PIPE = 1
)
(
   input   [IN_WIDTH - 1 : 0]  opa_R,
   input   [IN_WIDTH - 1 : 0]  opa_I,
   input   [IN_WIDTH - 1 : 0]  opb_R,
   input   [IN_WIDTH - 1 : 0]  opb_I,
   // only useful if ARITH_MODE == 2
   input                       arith_mode_R,
   input                       arith_mode_I,
   // only useful if COPLEX_MODE == 2
   input                       flip,
   input   [$clog2(2*IN_WIDTH + 1) - 1 : 0] shift_amount,
   output  logic [OUT_WIDTH - 1 : 0]  out_R,
   output  logic [OUT_WIDTH - 1 : 0]  out_I,
   input                           clk,
   input                           rst_n
);

   logic signed [IN_WIDTH - 1 : 0] opa_R_sign, opa_I_sign, opb_R_sign, opb_I_sign;

   logic signed [2*IN_WIDTH - 1 : 0] aRbR, aRbI, aIbR, aIbI;

   logic [$clog2(2*IN_WIDTH) - 1 : 0] shift_zero;

   assign shift_zero = 0;

   assign opa_R_sign = opa_R;
   assign opa_I_sign = opa_I;
   assign opb_R_sign = opb_R;
   assign opb_I_sign = opb_I;

   fix_mult #(
      .IN_WIDTH(IN_WIDTH),
      .OUT_WIDTH(2*IN_WIDTH),
      .SHIFT_CONST(SHIFT_CONST),
      .SHIFT_MODE(0),
      .SAT_PIPE(0),
      .SHIFT_PIPE(0),
      .MULT_PIPE(MULT_PIPE)
   ) mult_arbr (
      .opa(opa_R_sign),
      .opb(opb_R_sign),
      .shift_amount(shift_zero),
      .out(aRbR),
      .*
   );

   fix_mult #(
      .IN_WIDTH(IN_WIDTH),
      .OUT_WIDTH(2*IN_WIDTH),
      .SHIFT_CONST(SHIFT_CONST),
      .SHIFT_MODE(0),
      .SAT_PIPE(0),
      .SHIFT_PIPE(0),
      .MULT_PIPE(MULT_PIPE)
   ) mult_arbi (
      .opa(opa_R_sign),
      .opb(opb_I_sign),
      .shift_amount(shift_zero),
      .out(aRbI),
      .*
   );

   fix_mult #(
      .IN_WIDTH(IN_WIDTH),
      .OUT_WIDTH(2*IN_WIDTH),
      .SHIFT_CONST(SHIFT_CONST),
      .SHIFT_MODE(0),
      .SAT_PIPE(0),
      .SHIFT_PIPE(0),
      .MULT_PIPE(MULT_PIPE)
   ) mult_aibr (
      .opa(opa_I_sign),
      .opb(opb_R_sign),
      .shift_amount(shift_zero),
      .out(aIbR),
      .*
   );

   fix_mult #(
      .IN_WIDTH(IN_WIDTH),
      .OUT_WIDTH(2*IN_WIDTH),
      .SHIFT_CONST(SHIFT_CONST),
      .SHIFT_MODE(0),
      .SAT_PIPE(0),
      .SHIFT_PIPE(0),
      .MULT_PIPE(MULT_PIPE)
   ) mult_aibi (
      .opa(opa_I_sign),
      .opb(opb_I_sign),
      .shift_amount(shift_zero),
      .out(aIbI),
      .*
   );

   fix_c_add_sub #(
      .IN_WIDTH(2*IN_WIDTH),
      .OUT_WIDTH(OUT_WIDTH),
      .ARITH_MODE_R(ARITH_MODE_R),
      .ARITH_MODE_I(ARITH_MODE_I),
      .FLIP(FLIP),
      .SHIFT_CONST(SHIFT_CONST),
      .SHIFT_MODE(SHIFT_MODE),
      .SAT_PIPE(SAT_PIPE),
      .SHIFT_PIPE(SHIFT_PIPE),
      .ADD_PIPE(ADD_PIPE)
   ) add_c_mult(
      .opa_R(aRbR),
      .opa_I(aRbI),
      .opb_R(aIbI),
      .opb_I(aIbR),
      .arith_mode_R(arith_mode_R), 
      .arith_mode_I(arith_mode_I),
      .flip(flip),
      .shift_amount(shift_amount),
      .out_R(out_R),
      .out_I(out_I),
      .* 
   );  

    

endmodule
