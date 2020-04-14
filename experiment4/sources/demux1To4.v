module demux4 (
    input data,
    input [1:0] signal,
    output [3:0] y
    );
    
    y[0] = ~s[1] & ~s[0] & data;
    y[1] = ~s[1] & s[0] & data;
    y[2] = s[1] & ~s[0] & data;
    y[3] = s[1] & s[0] & data;
    
endmodule
