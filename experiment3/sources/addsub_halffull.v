module addsub_halffull (
    input mode_addsub, // ADDER at 0, SUBTRACTOR at 1
    input mode_halffull, // HALF at 0, FULL at 1
    input signal_a,
    input signal_b,
    input carryborrow_in, // CARRY at mode_addsub == 0, BORROW at mode_addsub == 1
    output carryborrow_out, // CARRY at mode_addsub == 0, BORROW at mode_addsub == 1
    output sumdiff // SUM at mode_addsub == 0, DIFFERENCE at mode_addsub == 1
);

wire w_carryborrow_in;

assign w_carryborrow_in = carryborrow_in & mode_halffull;

assign carryborrow_out = (w_carryborrow_in & (signal_a ^ signal_b ^ mode_addsub)) | ((signal_a ^ mode_addsub) & signal_b);
assign sumdiff = signal_a ^ signal_b ^ w_carryborrow_in;

endmodule
