# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    clock = Clock(dut.clk, 1, units="ns")
    cocotb.start_soon(clock.start())

    # Check Reset Function
    dut.ui_in.value = 0
    dut.rst_n.value = 0     # Low to reset
    await ClockCycles(dut.clk, 2)  # Wait 10 cycles
    dut.rst_n.value = 1     # Exit reset
    await ClockCycles(dut.clk, 2)

    # Check high input
    dut.ui_in.value = 30
    await ClockCycles(dut.clk, 2)
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 10)



