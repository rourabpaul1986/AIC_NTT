`timescale 1ns/1ps


module btf_addsub #
(
    parameter integer LOGQ       = 0,
    parameter [LOGQ-1:0] MODULUS = 0,
    parameter integer WORD_SIZE  = 0,
    parameter integer LATENCY    = 0
)
(
    input  wire                   clk,
    input  wire [LOGQ-WORD_SIZE-1:0] mod_high,
    input  wire [LOGQ-1:0]          in_a,
    input  wire [LOGQ-1:0]          in_b,
    input  wire [LOGQ-1:0]          in_sub,
    output wire [LOGQ-1:0]          out_sum,
    output wire [LOGQ-1:0]          out_diff
);

    modadd #(
        .LOGQ(LOGQ),
        .Q_VALUE(MODULUS),
        .WORD_SIZE(WORD_SIZE),
        .MODADD_LAT(LATENCY)
    ) u_modadd (
        .clk(clk),
        .qH(mod_high),
        .a(in_a),
        .b(in_b),
        .e(out_sum)
    );

    modsub #(
        .LOGQ(LOGQ),
        .Q_VALUE(MODULUS),
        .WORD_SIZE(WORD_SIZE),
        .MODADD_LAT(LATENCY)
    ) u_modsub (
        .clk(clk),
        .qH(mod_high),
        .a(in_a),
        .f(in_sub),
        .o(out_diff)
    );

endmodule

