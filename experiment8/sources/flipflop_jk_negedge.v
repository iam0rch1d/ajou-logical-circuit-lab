module flipflop_jk_negedge(
    input clockpulse,
    input preset_,
    input clear_,
    input jack,
    input kilby,
    output reg signal_q,
    output reg signal_q_
);

always @(negedge clockpulse, negedge preset_, negedge clear_) begin
    if (~clear_) begin
        signal_q <= 1'b0;
        signal_q_ <= 1'b1;
    end
    else if (~preset_) begin
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
