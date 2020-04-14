module decoderBcdToDecimal (
    input [3:0] in,
    output reg [9:0] out
    );
    
    wire [3:0] wire_in;

    assign wire_in = in;

    always @(wire_in) begin
        case (wire_in)
            4'b0000: out = 10'b11_1111_1110;
            4'b0001: out = 10'b11_1111_1101;
            4'b0010: out = 10'b11_1111_1011;
            4'b0011: out = 10'b11_1111_0111;
            4'b0100: out = 10'b11_1110_1111;
            4'b0101: out = 10'b11_1101_1111;
            4'b0110: out = 10'b11_1011_1111;
            4'b0111: out = 10'b11_0111_1111;
            4'b1000: out = 10'b10_1111_1111;
            4'b1001: out = 10'b01_1111_1111;       
            default: out = 10'b11_1111_1111;
        endcase
    end
    
endmodule
