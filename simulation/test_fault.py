import math
import random
import numpy as np
import sys
import argparse
#from lib import *
from lib_signed import *
###################################################################
l=12
f=1
Y = random.getrandbits(l)
X = random.getrandbits(l)
X_b= l_binary(X, l)
print(f"X in Binary: {X_b}")
Z  = stuck0_random_bits(X, l+1, f)
Z_b= l_binary(Z, l)
print(f"Z in Binary: {Z_b}")
print(f"Hamming Distance: {hamming_distance(X, Z)}")