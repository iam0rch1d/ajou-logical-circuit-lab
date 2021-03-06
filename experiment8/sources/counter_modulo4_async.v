module counter_modulo4_async(
    input clockpulse,
    input clear_,
    output wire [1:0] signal_q,
    output wire [1:0] signal_q_
);

flipflop_jk_negedge bit1(
    .clockpulse(signal_q[0]),
    .preset_(1'b1),
    .clear_(clear_),
    .jack(1'b1),
    .kilby(1'b1),
    .signal_q(signal_q[1]),
    .signal_q_(signal_q_[1])
);

flipflop_jk_negedge bit0(
    .clockpulse(clockpulse),
    .preset_(1'b1),
    .clear_(clear_),
    .jack(1'b1),
    .kilby(1'b1),
    .signal_q(signal_q[0]),
    .signal_q_(signal_q_[0])
);

endmodule
