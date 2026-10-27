`default_nettype none

module tt_um_cmp8_24100791 (
    input  wire [7:0] ui_in,    // A
    output wire [7:0] uo_out,   // [0]=LT [1]=EQ [2]=GT [3]=MODE
    input  wire [7:0] uio_in,   // B
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    // 1 = co dau, 0 = khong dau (chan chon che do: cho giang vien xac nhan)
    wire sgn = rst_n;
    wire gt, eq, lt;

    cmp8 u_cmp (.a(ui_in), .b(uio_in), .sgn(sgn), .gt(gt), .eq(eq), .lt(lt));

    assign uo_out  = {4'b0000, sgn, gt, eq, lt};
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;      // uio toan bo la input

    wire _unused = &{ena, clk, 1'b0};
endmodule
