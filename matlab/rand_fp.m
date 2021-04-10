function a = rand_fp (b, num);
   a = randi([-2^(b-1) + 1, 2^(b-1)], num, 1);
end
