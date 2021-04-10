/*
   fix point shift

   SHIFT_MODE = 1: shift right by parameter SHIFT_CONST
   SHIFT_MODE = 2: shift right by input shift_amount
   SHIFT_MODE = 3: shift left by parameter SHIFT_CONST
   SHIFT_MODE = 4: shift left by input shift_amount

   SHIFT_PIPE: different stage of pipelined register inserted after shift
*/
module fix_shift #(
   parameter IN_WIDTH = 16,
   parameter OUT_WIDTH = 16,
   parameter SHIFT_CONST = 3,
   parameter SHIFT_MODE = 1,
   parameter SAT_PIPE = 1,
   parameter SHIFT_PIPE = 1
)
(
   input   [IN_WIDTH - 1  : 0]    in,
   input   [$clog2(IN_WIDTH) - 1 : 0] shift_amount,
   output  logic [OUT_WIDTH - 1 : 0]  out,
   input                              clk,
   input                              rst_n
);

   parameter INTER_WIDTH = (SHIFT_MODE < 3)  ? IN_WIDTH :
                           (SHIFT_MODE == 3) ? IN_WIDTH + SHIFT_CONST:
                                               2*IN_WIDTH;
   logic signed [IN_WIDTH - 1 : 0]    in_sign;
   logic signed [INTER_WIDTH - 1 : 0] in_ext, out_pre, out_for_sat;  
   
   assign in_sign = in;
   always_comb begin
      if (in_sign[IN_WIDTH - 1 : 0] == 1) begin
         in_ext[INTER_WIDTH - 1 : IN_WIDTH - 1 : 0] = '1;
      end
      else begin
         in_ext[INTER_WIDTH - 1 : IN_WIDTH - 1 : 0] = 0;
      end
   end
   
   assign in_ext[IN_WIDTH - 2 : 0] = in_sign[IN_WIDTH - 2 : 0];

   always_comb begin
      if (SHIFT_MODE == 1) out_pre = in_ext >>> SHIFT_CONST;
      else if (SHIFT_MODE == 2) out_pre = in_ext >>> shift_amount;
      else if (SHIFT_MODE == 3) out_pre = in_ext <<< SHIFT_CONST;
      else (SHIFT_MODE == 4) out_pre = in_ext <<< shift_amount;
   end 
   
   generate if (SHIFT_PIPE > 0) begin

      pipe_reg # (
         .WIDTH(OUT_WIDTH),
         .STAGE(SHIFT_PIPE)
      )p_shift
      (
         .in(out_pre),
         .out(out_for_sat),
         .*
      );
   end
   else begin

      assign out_for_sat = out_pre;
 
   end endgenerate 

   generate if (OUT_WIDTH == INTER_WIDTH) begin
      assign out = out_for_sat;
   end
   else begin
      fix_sat # (
         .IN_WIDTH(INTER_WIDTH),
         .OUT_WIDTH(OUT_WIDTH),
         .SAT_PIPE(SAT_PIPE)
      ) sat_shift 
      (
         .in(out_for_sat),
         .out(out),
         .*
      );
   end endgenerate

endmodule

 
