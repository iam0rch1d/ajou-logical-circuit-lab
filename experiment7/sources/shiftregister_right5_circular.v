module shiftregister_right5_circular (
    input clockpulse,
    input clear,
    input preset_enable,
    input [4:0] preset,
    output wire [4:0] signal_q,
    output wire [4:0] signal_q_
);

wire w_serial_input;

assign w_serial_input = signal_q[0];

flipflop_d bit4(.clockpulse(clockpulse),
                .preset(preset[4] & preset_enable),
                .clear(clear),
                .data(w_serial_input),
                .signal_q(signal_q[4]),
                .signal_q_(signal_q_[4])
);

flipflop_d bit3(.clockpulse(clockpulse),
                .preset(preset[3] & preset_enable),
                .clear(clear),
                .data(signal_q[4]),
                .signal_q(signal_q[3]),
                .signal_q_(signal_q_[3])
);

flipflop_d bit2(.clockpulse(clockpulse),
                .preset(preset[2] & preset_enable),
                .clear(clear),
                .data(signal_q[3]),
                .signal_q(signal_q[2]),
                .signal_q_(signal_q_[2])
);

flipflop_d bit1(.clockpulse(clockpulse),
                .preset(preset[1] & preset_enable),
                .clear(clear),
                .data(signal_q[2]),
                .signal_q(signal_q[1]),
                .signal_q_(signal_q_[1])
);

flipflop_d bit0(.clockpulse(clockpulse),
                .preset(preset[0] & preset_enable),
                .clear(clear),
                .data(signal_q[1]),
                .signal_q(signal_q[0]),
                .signal_q_(signal_q_[0])
);

endmodule
