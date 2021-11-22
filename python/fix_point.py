from math import *
from numpy import *
from random import *
from BW import *

#BW = 16


def sat_fp (data_in):
   global BW
   if (data_in > 2**(BW-1) - 1):
      out = 2**(BW-1) - 1
   elif (data_in < -2**(BW-1)) :
      out = -2**(BW-1)
   else :
      out = data_in;
  
   return out

def csat_fp (data_in):
   return complex(sat_fp (data_in.real), sat_fp(data_in.imag))

def shift_fp (data_in, mode, num):
# mode = 0 : shift right : truncate
# mode = 1 : shift left  : more precision
## Shifting
   if (mode == 0):
      if (data_in > 0): 
         out_pre = floor(data_in / (2**num));
      else:
         in_abs = data_in*(-1);
         out_abs = ceil(in_abs / (2**num));
         out_pre = out_abs*(-1);
   else:
      out_pre = data_in*(2**num);
# Saturation 
   return sat_fp(out_pre);
   
def quant_fp (data_in, num):
   num_pre_r = round(data_in.real*(2**num))
   num_pre_i = round(data_in.imag*(2**num))
   num_pre = complex (num_pre_r, num_pre_i)
   return csat_fp(num_pre)


def cshift_fp (data_in, mode, num):
   return complex(shift_fp (data_in.real, mode, num), shift_fp (data_in.imag, mode, num))

def add_fp (opa, opb):
   return csat_fp (opa + opb)

def sub_fp (opa, opb):
   return csat_fp (opa - opb)

def mult_fp (opa, opb, mode, num):
   if (mode == 0):
      return cshift_fp ((opa*opb), 0, num)
   else :
      return cshift_fp ((opa*conj(opb)), 0, num)

def rand_fp (num, quant):
   out = []
   for i in range (num) :
      num_base_r = random() - 0.5
      num_power_r = floor(random()*quant)
      num_r = floor(num_base_r * 2**num_power_r)
      num_base_i = random() - 0.5
      num_power_i = floor(random()*quant)
      num_i = floor(num_base_i * 2**num_power_i)
      out.append(complex(num_r, num_i))
   if (num != 1):
      return out
   return complex(num_r, num_i)

def rand_real_fp (num, quant):
   out = []
   for i in range (num) :
      num_base_r = random() - 0.5
      num_power_r = floor(random()*quant)
      num_r = floor(num_base_r * 2**num_power_r)
      out.append(num_r)
   if (num != 1):
      return out
   return complex(num_r, 0)


def rotate_cordic_fp (u, z) : 
   half_pi_fi = floor(pi*2^8/2)

   if (z > half_pi_fi) :
      x = -imag(u)
      y = real(u)
      z = z - half_pi_fi
   elif (z < -half_pi_fi):
      x = imag(u);
      y = -real(u)
      z = z + half_pi_fi
   else :
      x = real(u)
      y = imag(u)
      z = z
   
