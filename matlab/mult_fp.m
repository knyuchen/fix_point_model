function out  = mult_fp (opa, opb,mode, num)

% mode = 0 : normal
% mode = 1 : conjucate
%% mult
   if (mode == 0) 
      out_pre = opa * opb;
   else
      out_pre = opa * conj(opb);
   end
%%
%% shift
   out = cshift_fp(out_pre, 0, num);
%%
end

