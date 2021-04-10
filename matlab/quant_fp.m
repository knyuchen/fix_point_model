function out = quant_fp (in, num)
   
   out_pre = floor(in*2^num);
   
   out = csat_fp(out_pre);
end
