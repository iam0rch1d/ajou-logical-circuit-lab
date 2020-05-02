module flipflop_jk (
    input clockpulse,
    input preset,
    input clear,
    input jack,
    input kilby,
    output reg signal_q,
    output reg signal_q_
);

always @(posedge clockpulse, posedge preset, posedge clear) begin
    if (clear) begin
        signal_q <= 1'b0;
        signal_q_ <= 1'b1;
    end
    else if (preset) begin
        signal_q <= 1'b1;
        signal_q_ <= 1'b0;
    end
    else begin
        if (~jack & kilby) begin
            signal_q <= 1'b0;
            signal_q_ <= 1'b1;
        end
        else if (jack & ~kilby) begin
            signal_q <= 1'b1;
            signal_q_ <= 1'b0;
        end
        else if (jack & kilby) begin
            signal_q <= ~signal_q;
            signal_q_ <= ~signal_q_;
        end
    end
end

endmodule
