module decoder_bcd_to_decimal (
    input [3:0] signal_i,
    output reg [9:0] signal_o_
);

parameter ZERO  = 4'b0000;
parameter ONE   = 4'b0001;
parameter TWO   = 4'b0010;
parameter THREE = 4'b0011;
parameter FOUR  = 4'b0100;
parameter FIVE  = 4'b0101;
parameter SIX   = 4'b0110;
parameter SEVEN = 4'b0111;
parameter EIGHT = 4'b1000;
parameter NINE  = 4'b1001;

always @(signal_i) begin
    case (signal_i)
        ZERO:    signal_o_ = 10'b11_1111_1110;
        ONE:     signal_o_ = 10'b11_1111_1101;
        TWO:     signal_o_ = 10'b11_1111_1011;
        THREE:   signal_o_ = 10'b11_1111_0111;
        FOUR:    signal_o_ = 10'b11_1110_1111;
        FIVE:    signal_o_ = 10'b11_1101_1111;
        SIX:     signal_o_ = 10'b11_1011_1111;
        SEVEN:   signal_o_ = 10'b11_0111_1111;
        EIGHT:   signal_o_ = 10'b10_1111_1111;
        NINE:    signal_o_ = 10'b01_1111_1111;       
        default: signal_o_ = 10'b11_1111_1111;
    endcase
end

endmodule
