module encoderDecimalToExcess3 (
    input [5:0] in,
    output [3:0] out
    );

    assign out[0] = in[0] | in[2] | in[4];
    assign out[1] = in[0] | in[3] | in[4];
    assign out[2] = in[1] | in[2] | in[3] | in[4];
    assign out[3] = in[5];

endmodule
