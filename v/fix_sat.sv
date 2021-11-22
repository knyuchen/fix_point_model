/*
   fix point saturator

   SAT_PIPE: different stage of pipelined register inserted after sat

   Always assume IN_WIDTH != OUT_WIDTH

   Revisions:
      10/11/21: First Documentation, fixed OUT_WIDTH > IN_WIDTH case
 
*/

module fix_sat #(
   parameter IN_WIDTH = 64,
   parameter OUT_WIDTH = 32,
   parameter SAT_PIPE  = 1
)
(  
   input            [IN_WIDTH  - 1 : 0]  in,
   output logic     [OUT_WIDTH - 1 : 0]  out,
   input                                 clk,
   input                                 rst_n
);

   logic sign;
 
   assign sign = in[IN_WIDTH - 1];

   logic [OUT_WIDTH - 1 : 0] out_pre;
   
   logic over_flow;

/*
   Downsizing OUT_WIDTH < IN_WIDTH
*/
   generate if (OUT_WIDTH < IN_WIDTH) begin
      logic [IN_WIDTH - OUT_WIDTH - 1 : 0]  determinant;

/*
   Additional Part
   if determinant = '1, no overflow & negative
                  = '0, no overflow & positive
                      , overflow when saturating
*/

      assign determinant = in[IN_WIDTH - 1 : OUT_WIDTH - 1];
   
      assign over_flow = determinant != '1 && determinant != 0;


      always_comb begin
/*
   No overflow, keep it the same
*/
         if (over_flow == 0) out_pre = in [OUT_WIDTH - 1 : 0];
/*
   Overflow, clipping
*/
         else begin
            if (sign == 1) begin
               out_pre[OUT_WIDTH - 1] = 1;
               out_pre[OUT_WIDTH - 2 : 0] = 0;
            end
            else begin
               out_pre[OUT_WIDTH - 1] = 0;
               out_pre[OUT_WIDTH - 2 : 0] = '1;

            end
         end
      end

   end
   else begin
      assign out_pre [OUT_WIDTH - 1 : IN_WIDTH] = (in [IN_WIDTH - 1] == 1) ? '1 : 0;
      assign out_pre [IN_WIDTH - 1 : 0] = in;

   end endgenerate
 
   generate if (SAT_PIPE > 0) begin

      pipe_reg # (
         .WIDTH(OUT_WIDTH),
         .STAGE(SAT_PIPE)
      )p_sat
      (
         .in(out_pre),
         .out(out),
         .*
      );
   end
   else begin

      assign out = out_pre;
 
   end endgenerate 

endmodule
