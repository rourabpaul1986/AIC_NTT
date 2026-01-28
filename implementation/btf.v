`timescale 1ns/1ps

module btf_uni #
(
    parameter LOGQ = 0,
    parameter [LOGQ-1:0] Q_VALUE = 0,
    parameter WORD_SIZE = 0,
    parameter MODADD_LAT = 0,
    parameter INTMUL_LAT = 0,
    parameter INTMUL_TYPE = "",
    parameter MODRED_LAT = 0,
    parameter MODRED_TYPE = "default",
    parameter MODRED_L = 4,
    parameter MODRED_COREMUL_LAT = 1,
    parameter BTF_TYPE = "unified",
    parameter SHIFT_AE = 0,
    parameter DIV_BY_2 = 1
)
(
    input  clk,
    input  sel_dit,
    input  en_div2,
    input  [1:0] op,
    input  [LOGQ-1:0] mod_q,
    input  [LOGQ-1:0] in_a,
    input  [LOGQ-1:0] in_b,
    input  [LOGQ-1:0] in_w,
    output fault,
    output [LOGQ-1:0] out_e,
    output [LOGQ-1:0] out_o,
    output [LOGQ-1:0] add_res,
    output [LOGQ-1:0] sub_res,
    output [LOGQ-1:0] mul_res
);

wire mode_sel;
assign mode_sel = (BTF_TYPE == "unified") ? (op == 2'd0 ? sel_dit : 1'b1) :
                  (BTF_TYPE == "ct")      ? 1'b1 : 1'b0;

reg div2_d;
always_ff @(posedge clk)
  div2_d <= (op == 2'd0) ? en_div2 : 1'b0;

wire [LOGQ-1:0] as_in0, as_in1, as_bak;
wire [LOGQ-1:0] as_out0, as_out1;
wire [LOGQ:0]   chk_sum;

wire [LOGQ-1:0] mm_in0, mm_in1;
wire [LOGQ-1:0] mm_out0, mm_out1;
wire mm_fault;

wire mode_d0, mode_d1;

wire [LOGQ-1:0] bf_e, bf_o;
reg  [LOGQ-1:0] bf_e_d, bf_o_d;
wire [LOGQ-1:0] div_e, div_o;

shiftreg #(INTMUL_LAT+MODRED_LAT, 1) sr0 (clk, mode_sel, mode_d0);
shiftreg #(MODADD_LAT, 1)           sr1 (clk, mode_d0, mode_d1);

logic [LOGQ-WORD_SIZE-1:0] q_hi;
assign q_hi = mod_q[LOGQ-1:WORD_SIZE];

btf_addsub #(
  LOGQ, Q_VALUE, WORD_SIZE, MODADD_LAT
) u_addsub (
  clk, q_hi, as_in0, as_in1, as_bak, as_out0, as_out1
);

btf_modmul #(
  LOGQ, Q_VALUE, WORD_SIZE,
  INTMUL_LAT, INTMUL_TYPE,
  MODRED_LAT, MODRED_TYPE,
  MODRED_L, MODRED_COREMUL_LAT,
  SHIFT_AE
) u_modmul (
  clk, mod_q, mm_in0, mm_in1, in_w,
  mm_out0, mm_out1, mm_fault
);

assign mm_in0 = mode_sel ? in_a : as_out0;
assign mm_in1 = mode_sel ? in_b : as_out1;

assign as_in0 = mode_d0 ? mm_out0 : in_a;
assign as_in1 = mode_d0 ? mm_out1 : in_b;
assign as_bak = in_b;

assign bf_e = mode_d1 ? as_out0 : mm_out0;
assign bf_o = mode_d1 ? as_out1 : mm_out1;

generate
if (DIV_BY_2) begin
  divby2 #(LOGQ, Q_VALUE, WORD_SIZE, 1) div_e_i (clk, bf_e, q_hi, div_e);
  divby2 #(LOGQ, Q_VALUE, WORD_SIZE, 1) div_o_i (clk, bf_o, q_hi, div_o);

  always_ff @(posedge clk) begin
    bf_e_d <= bf_e;
    bf_o_d <= bf_o;
  end

  assign out_e = div2_d ? div_e : bf_e_d;
  assign out_o = div2_d ? div_o : bf_o_d;
end else begin
  assign out_e = bf_e;
  assign out_o = bf_o;
end
endgenerate

assign add_res = as_out0;
assign sub_res = as_out1;
assign mul_res = mm_out1;

assign chk_sum = as_in0[0] ? (as_out0 - as_out1) : (as_out0 + as_out1);
assign fault   = (chk_sum[LOGQ:1] != as_in0);

endmodule
