// ** DO NOT USE THIS MODULE **

module latch_jk_withenable(
    input enable,
    input jack,
    input kilby,
    output reg signal_q,
    output reg signal_q_
);

reg [1:0] r_firststage;

always @(enable, jack, kilby, signal_q, signal_q_) begin
    r_firststage[0] = ~(enable & jack & signal_q_);
    r_firststage[1] = ~(enable & kilby & signal_q);
    
    signal_q = ~(signal_q_ & r_firststage[0]);
    signal_q_ = ~(signal_q & r_firststage[1]);
end

endmodule
