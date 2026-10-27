import random

import cocotb
from cocotb.triggers import Timer


def model(a, b, sgn):
    """Mo hinh chuan doc lap: tra ve (GT, EQ, LT)."""
    sa = a - 256 if (sgn and a & 0x80) else a
    sb = b - 256 if (sgn and b & 0x80) else b
    return (int(sa > sb), int(a == b), int(sa < sb))


async def check(dut, a, b, sgn, name=""):
    dut.ui_in.value = a
    dut.uio_in.value = b
    dut.rst_n.value = sgn
    await Timer(1, "ns")
    out = int(dut.uo_out.value)
    got = ((out >> 2) & 1, (out >> 1) & 1, out & 1)
    exp = model(a, b, sgn)
    assert got == exp, f"{name} a={a} b={b} sgn={sgn}: got (GT,EQ,LT)={got}, exp={exp}"
    assert ((out >> 3) & 1) == sgn, f"{name}: MODE echo sai"


def init(dut):
    dut.ena.value = 1
    dut.clk.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0


@cocotb.test()
async def tc_bat_buoc(dut):
    init(dut)
    for v in (0, 1, 127, 128, 254, 255, 0x55):       # TC-01: A=B
        for s in (0, 1):
            await check(dut, v, v, s, "TC-01")
    await check(dut, 255, 0, 0, "TC-02")             # khong dau: GT
    await check(dut, 0, 255, 0, "TC-03")             # khong dau: LT
    await check(dut, 255, 0, 1, "TC-04")             # co dau: LT (-1 < 0)
    await check(dut, 0, 255, 1, "TC-05")             # co dau: GT


@cocotb.test()
async def tc_tu_xay_dung(dut):
    init(dut)
    for s in (0, 1):                                  # TC-06: bien 127/128
        await check(dut, 127, 128, s, "TC-06")
        await check(dut, 128, 127, s, "TC-06")
    await check(dut, 0xFF, 0xFE, 1, "TC-07")         # hai so am
    await check(dut, 0xFE, 0xFF, 1, "TC-07")
    for s in (0, 1):                                  # TC-08: chi khac bit thap nhat
        await check(dut, 1, 0, s, "TC-08")
        await check(dut, 0xFE, 0xFF, s, "TC-08")


@cocotb.test()
async def quet_ngau_nhien(dut):
    init(dut)
    random.seed(1)
    for _ in range(2000):
        await check(dut, random.randrange(256), random.randrange(256),
                    random.randrange(2), "random")
