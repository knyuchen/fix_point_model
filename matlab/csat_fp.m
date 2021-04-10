function out = csat_fp (in)
  
   out_real = sat_fp(real(in));
   out_imag = sat_fp(imag(in));
   
   out = out_real + sqrt(-1) * out_imag;
end
