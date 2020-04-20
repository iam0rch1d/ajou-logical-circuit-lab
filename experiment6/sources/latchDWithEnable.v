module latchDWithEnable (
    input enable,
    input data,
    output reg out,
    output reg notout
    );

    reg reg_outputFirstStage0;
    reg reg_outputFirstStage1;
    
    always@ (enable, data) begin
        reg_outputFirstStage0 = ~(enable & data);
        reg_outputFirstStage1 = ~(enable & ~data);
        
        out = ~(notout & reg_outputFirstStage0);
        notout = ~(out & reg_outputFirstStage1);
    end

endmodule
