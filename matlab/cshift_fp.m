function out = cshift_fp(in, mode, num)
   out_real = shift_fp(real(in), mode, num);
   out_imag = shift_fp(imag(in), mode, num);
   
   out = out_real + sqrt(-1) * out_imag;
end
