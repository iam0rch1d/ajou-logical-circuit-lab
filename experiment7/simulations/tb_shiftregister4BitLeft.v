module tb_shiftregister4BitLeft;
reg clockpulse;
reg clear;
reg enablePreset;
wire [3:0] out;
wire [3:0] notout;
integer i;

initial begin
    clockpulse = 1'b0;
    clear = 1'b1;
    enablePreset = 1'b0;
    i = 0;
    
    #10;
    clear = 1'b0;
    
    for (i = 0; i < 4'hf; i = i + 1) begin
        if (i == 0) begin
            enablePreset = 1'b1;
        end
        
        clockpulse = 1'b1;
        
        #5;
        clockpulse = 1'b0;
        enablePreset = 1'b0;
        
        #5;
    end
end

shiftregister4BitLeft dut(
    .clockpulse(clockpulse),
    .clear(clear),
    .serialInput(1'b0),
    .enablePreset(enablePreset),
    .preset(4'b0011),
    .out(out),
    .notout(notout)
    );

endmodule
