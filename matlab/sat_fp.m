function out = sat_fp (in)
  global BW;
%% Saturation
   if (in > 2^(BW-1) - 1) 
      out = 2^(BW-1) - 1;
   elseif (in < -2^(BW-1))
      out = -2^(BW-1);
   else 
      out = in;
   end 
%%
end
