module shiftregister_left4(
    input clockpulse,
    input clear,
    input serial_input,
    input preset_enable,
    input [3:0] preset,
    output wire [3:0] signal_q,
    output wire [3:0] signal_q_
);

flipflop_jk bit3(
    .clockpulse(clockpulse),
    .preset(preset[3] & preset_enable),
    .clear(clear),
    .jack(signal_q[2]),
    .kilby(signal_q_[2]),
    .signal_q(signal_q[3]),
    .signal_q_(signal_q_[3])
);

flipflop_jk bit2(
    .clockpulse(clockpulse),
    .preset(preset[2] & preset_enable),
    .clear(clear),
    .jack(signal_q[1]),
    .kilby(signal_q_[1]),
    .signal_q(signal_q[2]),
    .signal_q_(signal_q_[2])
);

flipflop_jk bit1(
    .clockpulse(clockpulse),
    .preset(preset[1] & preset_enable),
    .clear(clear),
    .jack(signal_q[0]),
    .kilby(signal_q_[0]),
    .signal_q(signal_q[1]),
    .signal_q_(signal_q_[1])
);

flipflop_jk bit0(
    .clockpulse(clockpulse),
    .preset(preset[0] & preset_enable),
    .clear(clear),
    .jack(serial_input),
    .kilby(~serial_input),
    .signal_q(signal_q[0]),
    .signal_q_(signal_q_[0])
);

endmodule
