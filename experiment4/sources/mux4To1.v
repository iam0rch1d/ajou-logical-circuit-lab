module mux4To1 (
    input enable,
    input [1:0] signal,
    input [3:0] data,
    output y
    );
    
    wire u1a;
    wire u1b;
    wire u2a;
    wire u2b;
    
    assign u1a = ~(~signal[1] & ~signal[0] & ~enable & data[0]);
    assign u1b = ~(~signal[1] & signal[0] & ~enable & data[1]);
    assign u2a = ~(signal[1] & ~signal[0] & ~enable & data[2]);
    assign u2b = ~(signal[1] & signal[0] & ~enable & data[3]);
    assign y = ~(u1a & u1b & u2a & u2b);
    
endmodule
