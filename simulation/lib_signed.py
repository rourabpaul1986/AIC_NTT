import math
import random
import numpy as np
import sys
import argparse
##################################################################################
# Utility Functions
##################################################################################
def sum_of_array(arr):
    total = 0
    for num in arr:
        total += num
    return total
def hamming_distance(x, y):
    """
    Return the Hamming distance between two decimal integers.
    """
    return bin(x ^ y).count("1")
##########convert Binary################        
    
'''def l_binary(decimal, l):
    """Return binary representation of a number with l bits."""
    binary = bin(decimal)[2:]
    return binary.zfill(l) '''  
def l_binary(decimal, l):
    """
    Return l-bit two's complement binary representation
    (works for positive and negative numbers)
    """
    return format(decimal & ((1 << l) - 1), f'0{l}b')

 ###############random fault##############   
'''def flip_random_bits(decimal, l, n):
    """
    Flip n random bits in an l-bit two's-complement representation.
    """
    # two's complement masking
    masked = decimal & ((1 << l) - 1)
    bits = list(format(masked, f'0{l}b'))

    positions = random.sample(range(l), n)

    for pos in positions:
        bits[pos] = '1' if bits[pos] == '0' else '0'

    # convert back to signed integer
    faulty_unsigned = int(''.join(bits), 2)

    # convert unsigned → signed (two's complement)
    if faulty_unsigned >= (1 << (l - 1)):
        faulty_unsigned -= (1 << l)

    return faulty_unsigned'''
def flip_random_bits(decimal, l, n):
    """
    Flip n random bits in a length-l binary representation of 'decimal'
    and return the resulting integer.
    """
    bits = list(l_binary(decimal, l))
    # choose n unique bit positions
    positions = random.sample(range(l), n)

    # flip bits
    for pos in positions:
        bits[pos] = '1' if bits[pos] == '0' else '0'
   
    # convert binary string → decimal
    faulty_decimal = int(''.join(bits), 2)

    return faulty_decimal
################burst fault######################
def flip_burst_bits(decimal, l, n):
    """
    Flip n consecutive bits in a binary string at a random position.

    Args:
    binary_str (str): Input binary string.
    n (int): Number of consecutive bits to flip.

    Returns:
    str: Binary string with n consecutive bits flipped.
    """
    # Convert binary string to a list of characters for mutability
    binary_list = list(l_binary(decimal, l))
    
    # Get the length of the binary string
    length = len(binary_list)
    
    # Ensure we can flip n bits
    if n > length:
        raise ValueError("Burst size n cannot be larger than the binary string length.")
    
    # Choose a random starting position for the burst
    start_pos = random.randint(0, length - n)
    
    # Flip n consecutive bits starting from start_pos
    for i in range(start_pos, start_pos + n):
        binary_list[i] = '1' if binary_list[i] == '0' else '0'
    
     # convert binary string → decimal
    faulty_decimal = int(''.join(binary_list), 2)
    # Convert the list back to a string and return it
    return faulty_decimal
 ###############random  stuck 0 fault##############   
def stuck0_random_bits(decimal, l, n):
    """
    Flip n random bits in a length-l binary representation of 'decimal'
    and return the resulting integer.
    """
    bits = list(l_binary(decimal, l))

    # choose n unique bit positions
    positions = random.sample(range(l), n)

    # flip bits
    for pos in positions:
        bits[pos] = '0' 
   
    # convert binary string → decimal
    faulty_decimal = int(''.join(bits), 2)

    return faulty_decimal
    
 ###############random  stuck 0 fault##############   
def stuck1_random_bits(decimal, l, n):
    """
    Flip n random bits in a length-l binary representation of 'decimal'
    and return the resulting integer.
    """
    bits = list(l_binary(decimal, l))

    # choose n unique bit positions
    positions = random.sample(range(l), n)

    # flip bits
    for pos in positions:
        bits[pos] = '1' 
   
    # convert binary string → decimal
    faulty_decimal = int(''.join(bits), 2)

    return faulty_decimal
########
################stuck at 0 burst fault######################
def stuck0_burst_bits(decimal, l, n):
    """
    Flip n consecutive bits in a binary string at a random position.

    Args:
    binary_str (str): Input binary string.
    n (int): Number of consecutive bits to flip.

    Returns:
    str: Binary string with n consecutive bits flipped.
    """
    # Convert binary string to a list of characters for mutability
    binary_list = list(l_binary(decimal, l))
    
    # Get the length of the binary string
    #length = len(binary_list)
    length = l
    # Ensure we can flip n bits
    if n > length:
        raise ValueError("Burst size n cannot be larger than the binary string length.")
    
    # Choose a random starting position for the burst
    start_pos = random.randint(0, length - n)
    
    # Flip n consecutive bits starting from start_pos
    for i in range(start_pos, start_pos + n):
        binary_list[i] = '0'
    
     # convert binary string → decimal
    faulty_decimal = int(''.join(binary_list), 2)
    # Convert the list back to a string and return it
    return faulty_decimal
    
 ################stuck at 1 burst fault######################
def stuck1_burst_bits(decimal, l, n):
    """
    Flip n consecutive bits in a binary string at a random position.

    Args:
    binary_str (str): Input binary string.
    n (int): Number of consecutive bits to flip.

    Returns:
    str: Binary string with n consecutive bits flipped.
    """
    # Convert binary string to a list of characters for mutability
    binary_list = list(l_binary(decimal, l))
    
    # Get the length of the binary string
    length = len(binary_list)
    
    # Ensure we can flip n bits
    if n > length:
        raise ValueError("Burst size n cannot be larger than the binary string length.")
    
    # Choose a random starting position for the burst
    start_pos = random.randint(0, length - n)
    
    # Flip n consecutive bits starting from start_pos
    for i in range(start_pos, start_pos + n):
        binary_list[i] = '1'
    
     # convert binary string → decimal
    faulty_decimal = int(''.join(binary_list), 2)
    # Convert the list back to a string and return it
    return faulty_decimal   
 ###########################################   
def rule_check(l, w, N):
    """Check validity of parameters."""
    if l % w != 0:
        print(f"Error: l={l} must be divisible by w={w}")
        sys.exit(1)
    n = math.ceil(math.log2(N))
    if l <= n:
        print(f"Error: l={l} must be greater than bits required for N={N}")
        sys.exit(1)





def generate_random_numbers(n, a, b):
    return [random.randint(a, b) for _ in range(n)]
    
def AIC(add, sub, u, v, v_dash, M, j, err, no_err, verbose):
    """
    Arithmetic Invariant Checker:
    add = u + v
    sub = u - v
    Checks if both invariants hold.
    """
    #err = 0
    if verbose:
        print(f"add: {add}, sub: {sub}, u: {u}, v: {v}")
    if(j%2==0):
        if (((add + sub) )>> 1) != u:
            err =err+1
            #print(f"for fault u+v: {add}, u-v': {sub}, u: {u}, v: {v}, v_dash: {v_dash}")
        else:
            no_err =no_err+1
            #print(f"even for no fault u+v: {add}, u-v': {sub}, u: {u}, v: {v}, v_dash: {v_dash}")
    if(j%2==1):    
        if ((add - sub) >> 1) != v_dash:
         err =err+1
         #print(f"for fault u+v: {add}, u-v': {sub}, u: {u}, v: {v}, v_dash: {v_dash}")
        else:
         no_err =no_err+1
         #print(f"odd for no fault u+v: {add}, u-v': {sub}, u: {u}, v: {v}, v_dash: {v_dash}")
    return err, no_err



##################################################################################
# Montgomery Multiplication
##################################################################################

def word_wise_montgomery_multiplication(A, B, N, N_prime, l, w, b, R, f, verbose):
    T = 0
    Tf = 0
    m = l // w
    fault = [0] * m

    #unfault_A = A
    #fault_A = flip_random_bits(A, f)

    for i in range(m):
        T0 = T % b
        B0 = B[-w:]
        Aw = A[-w:]
        At = A[-w:]
        #k = random.randint(0, 10)
        #Awf = (int(At, 2) + (k * b)) % b

        u = ((T0 + int(Aw, 2) * int(B0, 2)) * N_prime) % b
        #u_f = ((T0 + Awf * int(B0, 2)) * N_prime) % b
        #if u != u_f:
        #    fault[i] = 1

        T = (T + (int(Aw, 2) * int(B, 2)) + (u * N)) // b
        #Tf = (Tf + (Awf * int(B, 2)) + (u * N)) // b

        #fault_A = fault_A[:-w]
        A = A[:-w]

    if T >= N:
        T -= N
    T = T * R % N
    return T


def mont_mult_top(l, w, A, B, N, f, verbose):
    b = 2 ** w
    N_prime = pow(-N, -1, b)
    R = 2 ** l

    A_bin = l_binary(A, l)
    B_bin = l_binary(B, l)
    result = word_wise_montgomery_multiplication(A_bin, B_bin, N, N_prime, l, w, b, R, f, verbose)
    return result

def split_mul(alpha, omega, l, chunk):
    assert l >= chunk
    #half = l//chunk
    half = chunk
    mask = (1<<half)-1

    alpha_h = alpha >> half
    alpha_l = alpha & mask
    omega_h = omega >> half
    omega_l = omega & mask
    L = (alpha_l * omega_l) % 2**half
    return L
##################################################################################
# Modular Arithmetic and Helpers
##################################################################################

def modmult(a, b, M):
    return (a * b) % M


def modpow(alpha, n, M):
    if n == 0:
        return 1
    p = 1
    for b in bin(n)[2:]:
        p = modmult(p, p, M)
        if b == '1':
            p = modmult(p, alpha, M)
    return p


def is_primitive(alpha, N, M):
    for i in range(1, N):
        if modpow(alpha, i, M) == 1:
            return False
    return modpow(alpha, N, M) == 1


def find_primitive(N, M):
    for alpha in range(2, M):
        if is_primitive(alpha, N, M):
            return alpha
    return 0


def findinv(alpha, M):
    for i in range(M):
        if modmult(alpha, i, M) == 1:
            return i


def bit_reverse(x, n):
    if isinstance(x, int):
        b = '{:0{width}b}'.format(x, width=n)
        return int(b[::-1], 2)
    else:
        x_out = np.zeros(len(x), dtype=int)
        for i in range(len(x)):
            x_out[i] = x[bit_reverse(i, n)]
        return x_out


def inject_fault_partial(
    injection, mode,
    v_mult, u, 
    l, f, M, L, chunk
):
    """
    Perform fault injection based on injection type and mode.

    Returns:
        u_plus_v, u_minus_v
    """

    match (injection, mode):


            case ("fr", "mxx"):

                v = flip_random_bits(v_mult, 2*l, f) 
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = u + (v % M)
                u_minus_v = u - (v_dash % M)

            case ("fr", "xax"):

                v = v_mult
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = flip_random_bits(u + (v % M), l+1, f)
                u_minus_v = u - (v_dash % M)
                
            case ("fr", "xxs"):

                v = v_mult
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = u+(v % M)
                u_minus_v = flip_random_bits(u - (v_dash % M), l, f)
                
            case ("fr", "mas"):

                v = flip_random_bits(v_mult, 2*l, f)
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = flip_random_bits(u + v, l+1, f)
                u_minus_v = flip_random_bits(u - v_dash, l, f)
            # ---------------- Burst fault ----------------
            case ("fb", "mxx"):

                v = flip_burst_bits(v_mult, 2*l, f) 
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = u + (v % M)
                u_minus_v = u - (v_dash % M)


            case ("fb", "xax"):

                v = v_mult
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = flip_burst_bits(u + (v % M), l+1, f)
                u_minus_v = u - (v_dash % M)
            case ("fb", "xxs"):

                v = v_mult
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = u+(v % M)
                u_minus_v = flip_burst_bits(u - (v_dash % M), l, f)
            case ("fb", "mas"):

                v = flip_burst_bits(v_mult, 2*l, f)
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = flip_burst_bits(u + v, l+1, f)
                u_minus_v = flip_burst_bits(u - v_dash, l, f)

            # ---------------- Stuck-at random 0 SR0----------------
            case ("sr0", mxx):

                v = stuck0_random_bits(v_mult, 2*l, f)
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = u + (v % M)
                u_minus_v = u - (v_dash % M)

            case ("sr0", "sax"):

                v = v_mult
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = stuck0_random_bits(u + (v % M), l+1, f)
                u_minus_v = u - (v_dash % M)
            case ("sr0", "xxs"):

                v = v_mult
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = u+(v % M)
                u_minus_v = stuck0_random_bits(u - (v_dash % M), l, f)
            case ("sr0", "mas"):

                v = stuck0_random_bits(v_mult, 2*l, f)
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = stuck0_random_bits(u + (v % M), l+1, f)
                u_minus_v = stuck0_random_bits(u - (v_dash % M), l, f)
            # ---------------- Stuck-at random 1 -SR1---------------
            case ("sr1", mxx):

                v = stuck1_random_bits(v_mult, 2*l, f)
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = u + (v % M)
                u_minus_v = u - (v_dash % M)

            case ("sr1", "sax"):

                v = v_mult
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = stuck1_random_bits(u + (v % M), l+1, f)
                u_minus_v = u - (v_dash % M)
            case ("sr1", "xxs"):

                v = v_mult 
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = u+(v % M)
                u_minus_v = stuck1_random_bits(u - (v_dash % M), l, f)
            case ("sr1", "mas"):

                v = stuck1_random_bits(v_mult, 2*l, f)
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = stuck1_random_bits(u + (v % M), l+1, f)
                u_minus_v = stuck1_random_bits(u - (v_dash % M), l, f)

            # ---------------- Stuck-at burst 0 ---------sb0-------
            #case ("sb0", _):
            case ("sb0", mxx):

                v = stuck0_burst_bits(v_mult, 2*l, f)
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = u + (v % M)
                u_minus_v = u - (v_dash % M)

            case ("sb0", "xax"):

                v = v_mult 
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = stuck0_burst_bits(u + (v % M), l+1, f)
                u_minus_v = u - (v_dash % M)
            case ("sb0", "xxs"):

                v = v_mult
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = u+(v % M)
                u_minus_v = stuck0_burst_bits(u - (v_dash % M), l, f)
            case ("sb0", "mas"):

                v = stuck0_burst_bits(v_mult, 2*l, f)
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = stuck0_burst_bits(u + (v % M), l+1, f)
                u_minus_v = stuck0_burst_bits(u - (v_dash % M), l, f)

            # ---------------- Stuck-at burst 1 ----------------
            
            case ("sb1", mxx):

                v = stuck1_burst_bits(v_mult, 2*l, f)
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = u + (v % M)
                u_minus_v = u - (v_dash % M)

            case ("sb1", "sax"):

                v = v_mult
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = stuck1_burst_bits(u + (v % M), l+1, f)
                u_minus_v = u - (v_dash % M)
            case ("sb0", "xxs"):

                v = v_mult
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = u+(v % M)
                u_minus_v = stuck1_burst_bits(u - (v_dash % M), l, f)
            case ("sb0", "mas"):
                v = stuck1_burst_bits(v_mult, 2*l, f)
                if v!=0: 
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
                else:
                  v_dash = ((v // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V
                u_plus_v  = stuck1_burst_bits(u + (v % M), l+1, f)
                u_minus_v = stuck1_burst_bits(u - (v_dash % M), l, f)

            # ---------------- Unknown mode ----------------
            case _:
                print(f"The selected fault injection method {injection} is not available")
                exit()



    return v, u_plus_v, u_minus_v, v_dash


def inject_fault_full(
    injection, mode,
    v_mult, u, v_dash,
    l, f, M
):
    """
    Perform fault injection based on injection type and mode.

    Returns:
        u_plus_v, u_minus_v
    """

    match (injection, mode):


            case ("fr", "mxx"):
                if v_mult != 0:
                    v = flip_random_bits(v_mult, 2*l, f) % M
                else:
                    v = flip_random_bits(v_mult, 2*l, f)
                u_plus_v  = u + v
                u_minus_v = u - v_dash

            case ("fr", "xax"):
                if v_mult != 0:
                    v = v_mult % M
                else:
                    v = v_mult
                u_plus_v  = flip_random_bits(u + v, l+1, f)
                u_minus_v = u - v_dash
            case ("fr", "xxs"):
                if v_mult != 0:
                    v = v_mult % M
                else:
                    v = v_mult
                u_plus_v  = u+v
                u_minus_v = flip_random_bits(u - v_dash, l, f)
            case ("fr", "mas"):
                if v_mult != 0:
                    v = flip_random_bits(v_mult, 2*l, f) % M
                else:
                    v = flip_random_bits(v_mult, 2*l, f)
                u_plus_v  = flip_random_bits(u + v, l+1, f)
                u_minus_v = flip_random_bits(u - v_dash, l, f)
            # ---------------- Burst fault ----------------
            case ("fb", mxx):
                if v_mult != 0:
                    v = flip_burst_bits(v_mult, 2*l, f) % M
                else:
                    v = flip_burst_bits(v_mult, 2*l, f)
                u_plus_v  = u + v
                u_minus_v = u - v_dash

            case ("fb", "xax"):
                if v_mult != 0:
                    v = v_mult % M
                else:
                    v = v_mult
                u_plus_v  = flip_burst_bits(u + v, l+1, f)
                u_minus_v = u - v_dash
            case ("fb", "xxs"):
                if v_mult != 0:
                    v = v_mult % M
                else:
                    v = v_mult
                u_plus_v  = u+v
                u_minus_v = flip_burst_bits(u - v_dash, l, f)
            case ("fb", "mas"):
                if v_mult != 0:
                    v = flip_burst_bits(v_mult, 2*l, f) % M
                else:
                    v = flip_burst_bits(v_mult, 2*l, f)
                u_plus_v  = flip_burst_bits(u + v, l+1, f)
                u_minus_v = flip_burst_bits(u - v_dash, l, f)

            # ---------------- Stuck-at random 0 SR0----------------
            case ("sr0", mxx):
                if v_mult != 0:
                    v = stuck0_random_bits(v_mult, 2*l, f) % M
                else:
                    v = stuck0_random_bits(v_mult, 2*l, f)
                u_plus_v  = u + v
                u_minus_v = u - v_dash

            case ("sr0", "sax"):
                if v_mult != 0:
                    v = v_mult % M
                else:
                    v = v_mult
                u_plus_v  = stuck0_random_bits(u + v, l+1, f)
                u_minus_v = u - v_dash
            case ("sr0", "xxs"):
                if v_mult != 0:
                    v = v_mult % M
                else:
                    v = v_mult
                u_plus_v  = u+v
                u_minus_v = stuck0_random_bits(u - v_dash, l, f)
            case ("sr0", "mas"):
                if v_mult != 0:
                    v = stuck0_random_bits(v_mult, 2*l, f) % M
                else:
                    v = stuck0_random_bits(v_mult, 2*l, f)
                u_plus_v  = stuck0_random_bits(u + v, l+1, f)
                u_minus_v = stuck0_random_bits(u - v_dash, l, f)
            # ---------------- Stuck-at random 1 -SR1---------------
            case ("sr1", mxx):
                if v_mult != 0:
                    v = stuck1_random_bits(v_mult, 2*l, f) % M
                else:
                    v = stuck1_random_bits(v_mult, 2*l, f)
                u_plus_v  = u + v
                u_minus_v = u - v_dash

            case ("sr1", "sax"):
                if v_mult != 0:
                    v = v_mult % M
                else:
                    v = v_mult
                u_plus_v  = stuck1_random_bits(u + v, l+1, f)
                u_minus_v = u - v_dash
            case ("sr1", "xxs"):
                if v_mult != 0:
                    v = v_mult % M
                else:
                    v = v_mult 
                u_plus_v  = u+v
                u_minus_v = stuck1_random_bits(u - v_dash, l, f)
            case ("sr0", "mas"):
                if v_mult != 0:
                    v = stuck1_random_bits(v_mult, 2*l, f) % M
                else:
                    v = stuck1_random_bits(v_mult, 2*l, f)
                u_plus_v  = stuck1_random_bits(u + v, l+1, f)
                u_minus_v = stuck1_random_bits(u - v_dash, l, f)

            # ---------------- Stuck-at burst 0 ---------sb0-------
            #case ("sb0", _):
            case ("sb0", mxx):
                if v_mult != 0:
                    v = stuck0_burst_bits(v_mult, 2*l, f) % M
                else:
                    v = stuck0_burst_bits(v_mult, 2*l, f)
                u_plus_v  = u + v
                u_minus_v = u - v_dash

            case ("sb0", "sax"):
                if v_mult != 0:
                    v = v_mult % M
                else:
                    v = v_mult 
                u_plus_v  = stuck0_burst_bits(u + v, l+1, f)
                u_minus_v = u - v_dash
            case ("sb0", "xxs"):
                if v_mult != 0:
                    v = v_mult % M
                else:
                    v = v_mult
                u_plus_v  = u+v
                u_minus_v = stuck0_burst_bits(u - v_dash, l, f)
            case ("sb0", "mas"):
                if v_mult != 0:
                    v = stuck0_burst_bits(v_mult, 2*l, f) % M
                else:
                    v = stuck0_burst_bits(v_mult, 2*l, f)
                u_plus_v  = stuck0_burst_bits(u + v, l+1, f)
                u_minus_v = stuck0_burst_bits(u - v_dash, l, f)

            # ---------------- Stuck-at burst 1 ----------------
            #case ("sb1", _):
            case ("sb1", mxx):
                if v_mult != 0:
                    v = stuck1_burst_bits(v_mult, 2*l, f) % M
                else:
                    v = stuck1_burst_bits(v_mult, 2*l, f)
                u_plus_v  = u + v
                u_minus_v = u - v_dash

            case ("sb1", "sax"):
                if v_mult != 0:
                    v = v_mult % M
                else:
                    v = v_mult
                u_plus_v  = stuck1_burst_bits(u + v, l+1, f)
                u_minus_v = u - v_dash
            case ("sb0", "xxs"):
                if v_mult != 0:
                    v = v_mult % M
                else:
                    v = v_mult
                u_plus_v  = u+v
                u_minus_v = stuck1_burst_bits(u - v, l, f)
            case ("sb0", "mas"):
                if v_mult != 0:
                    v = stuck1_burst_bits(v_mult, 2*l, f) % M
                else:
                    v = stuck1_burst_bits(v_mult, 2*l, f)
                u_plus_v  = stuck1_burst_bits(u + v, l+1, f)
                u_minus_v = stuck1_burst_bits(u - v_dash, l, f)

            # ---------------- Unknown mode ----------------
            case _:
                print(f"The selected fault injection method {injection} is not available")
                exit()



    return v, u_plus_v, u_minus_v

