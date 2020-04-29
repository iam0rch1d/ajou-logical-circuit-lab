module flipflopJk (
    input clockpulse,
    input preset,
    input clear,
    input jack,
    input kilby,
    output reg out,
    output reg notout
    );

    always@ (posedge clockpulse, posedge preset, posedge clear) begin
        if (clear) begin
            out <= 1'b0;
            notout <= 1'b1;
        end
        else if (preset) begin
            out <= 1'b1;
            notout <= 1'b0;
        end
        else begin
            if (~jack & kilby) begin
                out <= 1'b0;
                notout <= 1'b1;
            end
            else if (jack & ~kilby) begin
                out <= 1'b1;
                notout <= 1'b0;
            end
            else if (jack & kilby) begin
                out <= ~out;
                notout <= ~notout;
            end
        end
    end

endmodule
