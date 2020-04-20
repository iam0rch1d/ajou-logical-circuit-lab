module latchJkWithEnable (
    input enable,
    input jack,
    input kilby,
    output reg out,
    output reg notout
    );

    reg reg_outputFirstStage0;
    reg reg_outputFirstStage1;
    
    always@ (enable, jack, kilby, out, notout) begin
        reg_outputFirstStage0 = ~(enable & jack & notout);
        reg_outputFirstStage1 = ~(enable & kilby & out);
        
        out = ~(notout & reg_outputFirstStage0);
        notout = ~(out & reg_outputFirstStage1);
    end

endmodule
