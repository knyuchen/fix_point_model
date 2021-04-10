function out  = add_fp (opa, opb)

%% ADD
   out_pre = opa + opb;
%% Saturate
   out = csat_fp(out_pre);
end

