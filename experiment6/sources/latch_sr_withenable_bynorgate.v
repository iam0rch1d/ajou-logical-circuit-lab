// ** DO NOT USE THIS MODULE **

module latch_sr_withenable_bynorgate(
    input enable,
    input set,
    input reset,
    output reg signal_q,
    output reg signal_q_
);

reg [1:0] r_firststage;

always @(enable, set, reset) begin
    r_firststage[0] = ~(enable | reset);
    r_firststage[1] = ~(enable | set);
    
    signal_q = ~(signal_q_ | r_firststage[0]);
    signal_q_ = ~(signal_q | r_firststage[1]);
end

endmodule
