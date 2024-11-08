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
    await ClockCycles(dut.clk, 10)  # Wait 10 cycles
    dut.rst_n.value = 1     # Exit reset
    await ClockCycles(dut.clk, 10)

    dut.ui_in.value = 20  # Assign a known value to `current`
    await ClockCycles(dut.clk, 10)



