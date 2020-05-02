module flipflop_d (
    input clockpulse,
    input preset,
    input clear,
    input data,
    output reg signal_q,
    output reg signal_q_
);

always @(posedge clockpulse, posedge clear, posedge preset) begin
    if (clear) begin
        signal_q <= 1'b0;
        signal_q_ <= 1'b1;
    end
    else if (preset) begin
        signal_q <= 1'b1;
        signal_q_ <= 1'b0;
    end
    else begin
        signal_q <= data;
        signal_q_ <= ~data;
    end
end

endmodule
