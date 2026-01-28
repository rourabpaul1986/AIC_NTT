`timescale 1ns/1ps
`default_nettype wire

module modadd #
(
    parameter integer WIDTH      = 0,
    parameter [WIDTH-1:0] MODULUS = 0,
    parameter integer WORD_SIZE  = 0,
    parameter integer LATENCY    = 0
)
(
    input  wire                     clk,
    input  wire [WIDTH-WORD_SIZE-1:0] mod_high,
    input  wire [WIDTH-1:0]           in_a,
    input  wire [WIDTH-1:0]           in_b,
    output wire [WIDTH-1:0]           out_c
);

wire [WIDTH-WORD_SIZE-1:0] mod_high_sel;
wire [WIDTH:0]             sum_raw;
wire signed [WIDTH:0]      sum_sub;
wire [WIDTH-1:0]           sum_sel;

reg  [WIDTH:0]             sum_reg;
reg  [WIDTH-1:0]           sum_out_reg;

assign mod_high_sel = (MODULUS == 0) ? mod_high : MODULUS[WIDTH-1:WORD_SIZE];

assign sum_raw = in_a - in_b;

assign sum_sub = sum_reg - {mod_high_sel, {(WORD_SIZE-1){1'b0}}, 1'b1};

assign sum_sel = (sum_sub[WIDTH] == 1'b0) ? sum_sub[WIDTH-1:0] : sum_reg[WIDTH-1:0];

generate
    if (LATENCY == 2) begin
        always @(posedge clk) begin
            sum_reg     <= sum_raw;
            sum_out_reg <= sum_sel;
        end
    end
    else if (LATENCY == 1) begin
        always @(*) begin
            sum_reg = sum_raw;
        end
        always @(posedge clk) begin
            sum_out_reg <= sum_sel;
        end
    end
    else begin
        always @(*) begin
            sum_reg     = sum_raw;
            sum_out_reg = sum_sel;
        end
    end
endgenerate

assign out_c = sum_out_reg;

endmodule

`default_nettype none
