module shiftregister4BitRight (
    input clockpulse,
    input clear,
    input serialInput,
    input enablePreset,
    input [3:0] preset,
    output wire [3:0] out,
    output wire [3:0] notout
    );
    
    flipflopJk bit0(.clockpulse(clockpulse),
                    .preset(preset[0] & enablePreset),
                    .clear(clear),
                    .jack(serialInput),
                    .kilby(~serialInput),
                    .out(out[0]),
                    .notout(notout[0])
                    );

    flipflopJk bit1(.clockpulse(clockpulse),
                    .preset(preset[1] & enablePreset),
                    .clear(clear),
                    .jack(out[0]),
                    .kilby(notout[0]),
                    .out(out[1]),
                    .notout(notout[1])
                    );

    flipflopJk bit2(.clockpulse(clockpulse),
                    .preset(preset[2] & enablePreset),
                    .clear(clear),
                    .jack(out[1]),
                    .kilby(notout[1]),
                    .out(out[2]),
                    .notout(notout[2])
                    );

    flipflopJk bit3(.clockpulse(clockpulse),
                    .preset(preset[3] & enablePreset),
                    .clear(clear),
                    .jack(out[2]),
                    .kilby(notout[2]),
                    .out(out[3]),
                    .notout(notout[3])
                    );

endmodule
