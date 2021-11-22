/*
   fix point real number add / sub

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
   SHIFT_PIPE: different stage of pipelined register inserted after sat
   ADD_PIPE: different stage of pipelined register inserted after add / sub itself

   Revisions:
      10/11/21:
        First Documentation
*/

module fix_add_sub #(
   parameter IN_WIDTH = 16,
   parameter OUT_WIDTH = 16,
   parameter ARITH_MODE = 1,
   parameter FLIP = 0,
   parameter ADD_PIPE = 1,
   parameter SHIFT_CONST = 3,
   parameter SHIFT_MODE = 1,
   parameter SAT_PIPE = 1,
   parameter SHIFT_PIPE = 1
)
(
   input   [IN_WIDTH - 1 : 0]  opa,
   input   [IN_WIDTH - 1 : 0]  opb,
   // only useful if ARITH_MODE == 2
   input                       arith_mode,
   // only useful if FLIP == 2
   input                       flip,
   input   [$clog2(IN_WIDTH + 1) - 1 : 0] shift_amount,
   output  logic [OUT_WIDTH - 1 : 0]  out,
   input                       clk,
   input                       rst_n
);

/*
   Handles signed logic / flipping all at once
*/
   logic signed [IN_WIDTH - 1 : 0]  opa_sign, opb_sign;

   generate if (FLIP == 0) begin

      assign opa_sign = opa;
      assign opb_sign = opb;
   
   end
   else if (FLIP == 1) begin
      assign opa_sign = opb;
      assign opb_sign = opa;
   end
   else begin
      assign opa_sign = (flip == 0) ? opa : opb;
      assign opb_sign = (flip == 0) ? opb : opa;
   end endgenerate

   // extra bit for overflow
   parameter INTER_WIDTH = IN_WIDTH + 1;

   logic signed [INTER_WIDTH - 1 : 0] out_pre, out_for_shift;

   always_comb begin
      if (ARITH_MODE == 0) out_pre = opa_sign + opb_sign;
      else if (ARITH_MODE == 1) out_pre = opa_sign - opb_sign;
      else begin
         if (arith_mode == 0) out_pre = opa_sign + opb_sign;
         else out_pre = opa_sign - opb_sign;
      end   
   end

   generate if (ADD_PIPE != 0) begin

      pipe_reg # (
         .WIDTH(INTER_WIDTH),
         .STAGE(ADD_PIPE)
      )p_add
      (
         .in(out_pre),
         .out(out_for_shift),
         .*
      );
   end
   else begin

      assign out_for_shift = out_pre;

   end endgenerate 

   generate if (SHIFT_MODE != 0) begin  
 
      fix_shift #(
         .IN_WIDTH (INTER_WIDTH),
         .OUT_WIDTH(OUT_WIDTH),
         .SHIFT_CONST(SHIFT_CONST),
         .SHIFT_MODE(SHIFT_MODE),
         .SAT_PIPE (SAT_PIPE),
         .SHIFT_PIPE(SHIFT_PIPE)
      )shift_add
      (
      .in (out_for_shift),
      .shift_amount (shift_amount),
      .out (out),
      .*
   );
   end
   else if (INTER_WIDTH != OUT_WIDTH) begin
      fix_sat # (
         .IN_WIDTH(INTER_WIDTH),
         .OUT_WIDTH(OUT_WIDTH),
         .SAT_PIPE(SAT_PIPE)
      ) sat_add 
      (
         .in(out_for_shift),
         .out(out),
         .*
      );
   end
   else begin
       
      assign out = out_for_shift;
   
   end endgenerate

endmodule

