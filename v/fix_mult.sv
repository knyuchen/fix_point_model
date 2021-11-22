/*
   fix point mult

   mult --> shift --> sat

   SHIFT_MODE = 0: no shift
   SHIFT_MODE = 1: shift by parameter SHIFT_CONST
   SHIFT_MODE = 2: shift by input shift_amount

   SAT_PIPE: different stage of pipelined register inserted after sat
   SHIFT_PIPE: different stage of pipelined register inserted after shift
   MULT_PIPE: different stage of pipelined register inserted after mult itself


   Revisions:
     10/11/21:
       First Domumentation
*/
module fix_mult #(
   parameter IN_WIDTH = 16,
   parameter OUT_WIDTH = 16,
   parameter SHIFT_CONST = 3,
   parameter SHIFT_MODE = 1,
   parameter SAT_PIPE = 1,
   parameter SHIFT_PIPE = 1,
   parameter MULT_PIPE = 1
)
(
   input   [IN_WIDTH - 1 : 0]  opa,
   input   [IN_WIDTH - 1 : 0]  opb,
   input   [$clog2(2*IN_WIDTH) - 1 : 0] shift_amount,
   output  logic [OUT_WIDTH - 1 : 0]  out,
   input                              clk,
   input                              rst_n
);

   logic signed [IN_WIDTH - 1 : 0] opa_sign, opb_sign;

   parameter INTER_WIDTH = 2*IN_WIDTH;

   logic signed [INTER_WIDTH - 1 : 0] out_pre;
   logic signed [INTER_WIDTH - 1 : 0] out_for_shift;

   assign opa_sign = opa;
   assign opb_sign = opb;

   assign out_pre = opa_sign * opb_sign;

   generate if (MULT_PIPE != 0) begin
      pipe_reg # (
         .WIDTH(INTER_WIDTH),
         .STAGE(MULT_PIPE)
      )p_mult
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
   

   
