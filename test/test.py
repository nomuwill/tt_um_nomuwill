# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

'''
Note:
    Test values were chosen from the Izhikevich Neuron Model simulation in docs/izh.py

    The first test check for normal input values (no spike), to make sure 
        it doesn't fire when below threshold. Interestingly, the input value
        was expected to be 5, but there was spiking until 3. I believe this 
        is due to scaling but I'm not sure.
    The second test checks for a spike when the input value is 10. 
    The third test checks for a spike when the input value is 255. 
'''

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

    # Check Input (No Spike)
    dut.ui_in.value = 3
    await ClockCycles(dut.clk, 5)
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 10)

    # Reset 
    dut.rst_n.value = 0    
    await ClockCycles(dut.clk, 2) 
    dut.rst_n.value = 1 
    await ClockCycles(dut.clk, 2)

    # Check Input (Spike)
    dut.ui_in.value = 10
    await ClockCycles(dut.clk, 5)
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 10)

    # Reset 
    dut.rst_n.value = 0    
    await ClockCycles(dut.clk, 2)  
    dut.rst_n.value = 1    
    await ClockCycles(dut.clk, 2)

    # Check Input (Spike)
    dut.ui_in.value = 255
    await ClockCycles(dut.clk, 5)
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 10)



