`timescale 1ns/1ps
`default_nettype wire

module shiftreg #
(
    parameter DELAY = 0,
    parameter WIDTH = 0
)
(
    input                  clk,
    input  [WIDTH-1:0]      din,
    output [WIDTH-1:0]      dout
);

reg [WIDTH-1:0] pipe [DELAY-1:0];

always @(posedge clk) begin
    if (DELAY > 0)
        pipe[0] <= din;
end

generate
    for (genvar k = 0; k < DELAY-1; k = k + 1) begin : PIPE_GEN
        always @(posedge clk) begin
            pipe[k+1] <= pipe[k];
        end
    end
endgenerate

generate
    if (DELAY == 0)
        assign dout = din;
    else
        assign dout = pipe[DELAY-1];
endgenerate

endmodule
