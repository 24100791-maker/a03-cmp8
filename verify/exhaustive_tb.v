`timescale 1ns/1ps
module tb;
    reg [7:0] a, b; reg sgn;
    wire gt, eq, lt;
    cmp8 dut(a, b, sgn, gt, eq, lt);
    integer i, j, s, err;

    task check;
        reg egt, eeq, elt;
        begin
            #1;
            if (sgn) begin
                egt = ($signed(a) > $signed(b));
                eeq = (a == b);
                elt = ($signed(a) < $signed(b));
            end else begin
                egt = (a > b); eeq = (a == b); elt = (a < b);
            end
            if ({gt,eq,lt} !== {egt,eeq,elt}) begin
                err = err + 1;
                $display("LOI sgn=%b a=%0d b=%0d", sgn, a, b);
            end
        end
    endtask

    initial begin
        err = 0;
        for (s = 0; s < 2; s = s + 1)
            for (i = 0; i < 256; i = i + 1)
                for (j = 0; j < 256; j = j + 1) begin
                    sgn = s; a = i; b = j; check;
                end
        sgn = 0; a = 255; b = 0;   check;
        sgn = 0; a = 0;   b = 255; check;
        sgn = 1; a = 255; b = 0;   check;
        if (err == 0) $display("PASS");
        else          $display("FAIL: %0d loi", err);
        $finish;
    end
endmodule
