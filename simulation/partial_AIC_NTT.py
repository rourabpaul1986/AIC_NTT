import math
import random
import numpy as np
import sys
import argparse
#from lib import *
from lib_signed import *
###################################################################



def CT_Butterfly(i, j, n, x_out, A, twiddle_factor, M, length, f, l, w, array, tw_index, eqs, err, no_err, injection, mode, chunk, verbose):
    

    if length <= 1:
        x_out[0] = A[0]
        return x_out

    halflen = length >> 1

    for k in range(halflen):
        u = A[k]

        if verbose:
            print(f"i:{i}, j:{j}, k0:{k}, k1:{k+halflen}, : w{tw_index}:{twiddle_factor}, A[{k}]:{A[k]}, A[{k + halflen}]:{A[k + halflen]}")      

        #v = mont_mult_top(l, w, A[k + halflen], twiddle_factor, M, f, verbose=False)
        v_mult= twiddle_factor * A[k + halflen]
        #chunk=2
        L=split_mul(A[k + halflen], twiddle_factor, l, chunk) # this is for partial AIC
        #print(f"L: {L}")
        ####note v is faulty and v_dash not faulty
        v_mult, u_plus_v, u_minus_v, v_dash=inject_fault_partial(injection, mode, v_mult,  u, l, f, M, L, chunk)
        '''if v_mult!=0: 
         #v_dash = ((v_mult // (2 ** (l // chunk))) * (2 ** (l // chunk)) + L) % M #padd L and V
         v_dash = ((v_mult // (2 ** (chunk))) * (2 ** (chunk)) + L) % M #padd L and V
        else:
         #v_dash = ((v_mult // (2 ** (l // chunk))) * (2 ** (l // chunk)) + L) #padd L and V
         v_dash = ((v_mult // (2 ** (chunk))) * (2 ** (chunk)) + L) #padd L and V'''
        ###########################fault mode################################
        if v_mult!=0:
         v=v_mult % M
        else:
         v=v_mult
        if verbose:
            print(f"v: {v}, v_dash: {v_dash}, L: {L}")
        #print(f"v: {v} in binary : {v_bin}, v_fault: {v_fault}, hamming distance {hamming_distance(v, v_fault)}")
        x_out[k] = (u + v) % M
        x_out[k + halflen] = (u - v_dash) % M
        #x_out[k + halflen] = (u - v) % M
        error, no_error=AIC(u_plus_v, u_minus_v, u, v, v_dash, M, k, err, no_err, verbose)
        err=error
        no_err=no_error
        if verbose : 
         print(f"error: {error}")

    return array, error, no_error


##################################################################################
# NTT Class
##################################################################################

class fNTT:
    def __init__(self, N, M, alpha=None):
        self.N = N
        self.M = M
        self.Nlen = int(np.log2(N))
        self.Ninv = findinv(self.N, self.M)
        if alpha is not None and not is_primitive(alpha, N, M):
            raise ValueError('Given alpha is not primitive')
        self.alpha = alpha or find_primitive(N, M)
        if self.alpha == 0:
            raise ValueError('No primitive root exists')
        if verbose: print(f"initial omega (nth root of unity): {self.alpha}")
        self.alpha_modpow_table = [modpow(self.alpha, i, M) for i in range(N)]
        self.bit_reverse_table = [bit_reverse(i, self.Nlen - 1) for i in range(N // 2)]
        if verbose:  print(f"twiddle factors :{self.alpha_modpow_table}")
    def forward(self, x_in, N, f, l, w, eqs_f, err, no_err, injection, mode, chunk, verbose=False):
        if len(x_in) != self.N:
            raise ValueError(f'Input should be sized {self.N}')
        x = np.copy(x_in)
        array = N * [0]
        
        for i in range(self.Nlen):
            n = 1 << i
            seqlen = self.N // n
            for j in range(n):
                
                twiddle_factor = self.alpha_modpow_table[self.bit_reverse_table[j]]
                tw_index=self.bit_reverse_table[j]
                array, err, no_err= CT_Butterfly(i, j, n, x[seqlen * j: seqlen * (j + 1)],
                                     x[seqlen * j: seqlen * (j + 1)],
                                     twiddle_factor, self.M, seqlen, f, l, w, array, tw_index, eqs_f, err, no_err, injection, mode, chunk, verbose)
        return bit_reverse([i % self.M for i in x], self.Nlen), err, no_err

    def inverse(self, x_in, N, f, l, w, eqs_r, err, no_err, injection, mode, chunk, verbose=False):
        if len(x_in) != self.N:
            raise ValueError(f'Input should be sized {self.N}')
        x = np.copy(x_in)
        array = N * [0]
        for i in range(self.Nlen):
            n = 1 << i
            seqlen = self.N // n
            for j in range(n):
                twiddle_factor = self.alpha_modpow_table[(self.N - self.bit_reverse_table[j]) % N]
                tw_index=self.N - self.bit_reverse_table[j] % N
                array, err, no_err = CT_Butterfly(i, j, n, x[seqlen * j: seqlen * (j + 1)],
                                     x[seqlen * j: seqlen * (j + 1)],
                                     twiddle_factor, self.M, seqlen, f, l, w, array, tw_index, eqs_r, err, no_err, injection, mode, chunk, verbose)
        x = [modmult(i, self.Ninv, self.M) for i in x]
        return bit_reverse(x, self.Nlen), err, no_err


##################################################################################
# Validation Helper
##################################################################################

def check_arrays(array1, array2, verbose):
    if len(array1) != len(array2):
        print(f"Wrong: Arrays have different lengths. {len(array1)} {len(array2)}")
        return False
    for i in range(len(array1)):
        if array1[i] != array2[i]:
            print(f"P Wrong: Elements at index  {i} are different ({array1[i]} != {array2[i]}).")
            return False
            
    print("Bingo!! All elements match.")
    return True


##################################################################################
# Main Program
##################################################################################

if __name__ == "__main__":

    
    # -------- Argument parser --------
    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--samples", type=int, required=True,
                        help="Sample Size (integer value)")
    parser.add_argument("-f", "--fault", type=int, required=True,
                        help="Number of Faulty bits (integer value)")
    parser.add_argument("-a", "--application", type=str, required=True,
                        help="application PQC/FHE ")
    parser.add_argument("-i", "--injection", type=str, required=True,
                        help="fault injection type")
    parser.add_argument("-m", "--mode", type=str, required=True,
                        help="fault injected operations")
    parser.add_argument("-v", "--verbose", action="store_true",
                        help="Enable verbose mode")
    parser.add_argument("-c", "--chunk", type=int, required=True,
                        help="Number of partitions (integer value)")
    args = parser.parse_args()

    sample_size = args.samples
    verbose = args.verbose
    f = args.fault
    injection = args.injection
    mode = args.mode
    application = args.application
    chunk = args.chunk
    
    if application=="PQC": 
        N = 256
        M = 3329
        l = 12
    if application=="FHE": 
        N = 4096
        M=8404993
        l = 24
    if verbose:
        print("Verbose mode activated")
    pipe = math.ceil(math.log2(N))
    eqs_f = [[] for _ in range(N)]  # example: 256 sentences (or use len(A))
    eqs_r = [[] for _ in range(N)]  # example: 256 sentences (or use len(A))
    ntt = fNTT(N, M)
    
    w = l
    #f = 1
    err=0
    no_err=0
    print(f"######################PARTIAL AIC########################################")
    for i in range(sample_size):
        A = generate_random_numbers(N, 0, M-1)
        if verbose:
         print(f"Input Polynomial A of degree {len(A) - 1}: {A}")
        ntt_A, err, no_err = ntt.forward(A, N, f, l, w, eqs_f, err, no_err, injection, mode, chunk, verbose=verbose)
        sum=sum_of_array(ntt_A)
        if verbose:
         print(f"Forward NTT of A: {ntt_A}\n")
        #print(f"FError: {err}\n")
        if f==0:
            inv_ntt_A, err, no_err = ntt.inverse(ntt_A, N, f, l, w, eqs_r, err, no_err, injection, mode, chunk, verbose=verbose)
            if verbose:
                print(f"Reversed NTT of A: {inv_ntt_A}")
            check_arrays(inv_ntt_A, A, verbose)
        #print(f"RError: {err}\n")
    
    print(f"Effciency for Partial AIC: {100*err/(sample_size*(math.log2(N)*(N/2)))}%\n")
    #print(f"Error: {err} & noError: {no_err}\n")
    print(f"#########################################################################")
    #if verbose:

	
     
