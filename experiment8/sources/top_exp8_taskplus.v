module top_exp8_taskplus(
    input clockpulse,
    input clear_,
    output wire [2:0] counter_out,
    output wire [7:0] decoder_out
);

counter_modulo8_async counter(.clockpulse(clockpulse),
                              .clear_(clear_),
                              .signal_q(counter_out)
);

decoder_3to8 decoder(.signal_i(counter_out),
                     .signal_o(decoder_out);
);

endmodule
