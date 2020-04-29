module shiftregister5BitCircularRight (
    input clockpulse,
    input clear,
    input enablePreset,
    input [4:0] preset,
    output wire [4:0] out,
    output wire [4:0] notout
    );

    wire wire_serialInput;

    assign wire_serialInput = out[0];
    
    flipflopJk bit4(.clockpulse(clockpulse),
                    .preset(preset[4] & enablePreset),
                    .clear(clear),
                    .jack(serialInput),
                    .kilby(~serialInput),
                    .out(out[4]),
                    .notout(notout[4])
                    );

    flipflopJk bit3(.clockpulse(clockpulse),
                    .preset(preset[3] & enablePreset),
                    .clear(clear),
                    .jack(out[4]),
                    .kilby(notout[4]),
                    .out(out[3]),
                    .notout(notout[3])
                    );

    flipflopJk bit2(.clockpulse(clockpulse),
                    .preset(preset[2] & enablePreset),
                    .clear(clear),
                    .jack(out[3]),
                    .kilby(notout[3]),
                    .out(out[2]),
                    .notout(notout[2])
                    );

    flipflopJk bit1(.clockpulse(clockpulse),
                    .preset(preset[1] & enablePreset),
                    .clear(clear),
                    .jack(out[2]),
                    .kilby(notout[2]),
                    .out(out[1]),
                    .notout(notout[1])
                    );

    flipflopJk bit0(.clockpulse(clockpulse),
                    .preset(preset[0] & enablePreset),
                    .clear(clear),
                    .jack(out[1]),
                    .kilby(notout[1]),
                    .out(out[0]),
                    .notout(notout[0])
                    );
                    
endmodule
