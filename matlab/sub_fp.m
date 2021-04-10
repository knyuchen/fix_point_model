function out  = sub_fp (opa, opb)

%% SUB
   out_pre = opa - opb;
%%
%% Saturation
   out = csat_fp(out_pre);
%%
    
end

