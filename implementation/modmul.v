`timescale 1ns/1ps

module modmul #
(
    parameter integer WIDTH          = 0,
    parameter [WIDTH-1:0] MODULUS    = 0,
    parameter integer WORD_SIZE      = 0,
    parameter integer MUL_LATENCY    = 0,
    parameter string  MUL_TYPE       = "",
    parameter integer RED_LATENCY    = 0,
    parameter string  RED_TYPE       = "default",
    parameter integer RED_L          = 4,
    parameter integer RED_MUL_LAT    = 1,
    parameter integer SHIFT_INPUT    = 0
)
(
    input  wire                 clk,
    input  wire [WIDTH-1:0]     mod_q,
    input  wire [WIDTH-1:0]     in_a,
    input  wire [WIDTH-1:0]     in_b,
    input  wire [WIDTH-1:0]     twiddle,
    output wire [WIDTH-1:0]     out_e,
    output wire [WIDTH-1:0]     out_o,
    output wire [WIDTH-1:0]     out_o_fault
);

wire [2*WIDTH-1:0] mul_raw;
wire [2*WIDTH-1:0] mul_raw_fault;

shiftreg #(SHIFT_INPUT*(MUL_LATENCY+RED_LATENCY), WIDTH)
    shift_a_i (clk, in_a, out_e);

intmul #(WIDTH, WIDTH, MUL_LATENCY, MUL_TYPE)
    mul_i (clk, in_b, twiddle, mul_raw);

(* DONT_TOUCH = "yes" *)
intmul #(WIDTH, WIDTH, MUL_LATENCY, MUL_TYPE)
    mul_fault_i (clk, in_b, twiddle, mul_raw_fault);

modred #(WIDTH, MODULUS, WORD_SIZE, RED_LATENCY, RED_TYPE, RED_L, RED_MUL_LAT)
    red_i (clk, mul_raw, mod_q, out_o);

(* DONT_TOUCH = "yes" *)
modred #(WIDTH, MODULUS, WORD_SIZE, RED_LATENCY, RED_TYPE, RED_L, RED_MUL_LAT)
    red_fault_i (clk, mul_raw_fault, mod_q, out_o_fault);

endmodule
