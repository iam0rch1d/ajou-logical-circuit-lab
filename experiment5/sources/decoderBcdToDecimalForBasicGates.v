module decoderBcdToDecimalForBasicGates (
    input [3:0] in,
    output [9:0] out
    );

    // Active-high
    assign out[0] = ~in[3] & ~in[2] & ~in[1] & ~in[0];
    assign out[1] = ~in[3] & ~in[2] & ~in[1] & in[0];
    assign out[2] = ~in[3] & ~in[2] & in[1] & ~in[0];
    assign out[3] = ~in[3] & ~in[2] & in[1] & in[0];
    assign out[4] = ~in[3] & in[2] & ~in[1] & ~in[0];
    assign out[5] = ~in[3] & in[2] & ~in[1] & in[0];
    assign out[6] = ~in[3] & in[2] & in[1] & ~in[0];
    assign out[7] = ~in[3] & in[2] & in[1] & in[0];
    assign out[8] = in[3] & ~in[2] & ~in[1] & ~in[0];
    assign out[9] = in[3] & ~in[2] & ~in[1] & in[0];

endmodule
