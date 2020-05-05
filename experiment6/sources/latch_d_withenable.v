// ** DO NOT USE THIS MODULE **

module latch_d_withenable(
    input enable,
    input data,
    output reg signal_q,
    output reg signal_q_
);

reg [1:0] r_firststage;

always @(enable, data) begin
    r_firststage[0] = ~(enable & data);
    r_firststage[1] = ~(enable & ~data);
    
    signal_q = ~(signal_q_ & r_firststage[0]);
    signal_q_ = ~(signal_q & r_firststage[1]);
end

endmodule
