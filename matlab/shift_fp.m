function out  = shift_fp (in, mode, num)

% mode = 0 : shift right : truncate
% mode = 1 : shift left  : more precision
%% Shifting
   if (mode == 0)
      if (in > 0) 
         out_pre = floor(in / 2^num);
      else
         in_abs = in*(-1);
         out_abs = ceil(in_abs / 2^num);
         out_pre = out_abs*(-1);
      end   
   else 
      out_pre = in*2^num;
   end
%%
%% Saturation 
   out = sat_fp(out_pre);
end

