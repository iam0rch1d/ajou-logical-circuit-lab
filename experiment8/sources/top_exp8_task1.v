module top_exp8_task1(
    input clockpulse,
    input clear_,
    output wire [1:0] counter_out,
    output wire [3:0] decoder_out
);

counter_modulo4_async counter(.clockpulse(clockpulse),
                              .clear_(clear_),
                              .signal_q(counter_out)
);

decoder_2to4 decoder(.signal_i(counter_out),
                     .signal_o(decoder_out)
);

endmodule
