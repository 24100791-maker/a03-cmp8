module cmp8 (
    input  [7:0] a, b,
    input        sgn,          // 1 = có dấu, 0 = không dấu
    output       gt, eq, lt
);
    // Đảo bit MSB thì so sánh có dấu thành so sánh không dấu
    wire [7:0] ax = {a[7] ^ sgn, a[6:0]};
    wire [7:0] bx = {b[7] ^ sgn, b[6:0]};

    assign eq = (a == b);
    assign gt = (ax > bx);
    assign lt = (ax < bx);
endmodule
