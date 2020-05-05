module counter_bcd(
    input clockpulse,
    input clear_,
    output reg [3:0] signal_q
);

parameter ZERO = 4'b0000;
parameter NINE = 4'b1001;

always @(negedge clockpulse, negedge clear_) begin
    if (~clear_) begin
        signal_q <= ZERO;
    end
    else if (signal_q == NINE) begin
        signal_q <= ZERO;
    end
    else begin
        signal_q = signal_q + 1;
    end
end

endmodule
