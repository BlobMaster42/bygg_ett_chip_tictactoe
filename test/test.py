import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

# Expected sequences
RED = [int(b) for b in "000000001111111100000000"]
YELLOW = [int(b) for b in "000000001111111111111111"]
BLUE = [int(b) for b in "111111110000000000000000"]

# Pulse timings in ns
ZERO_HIGH = 400     # 0.4 us
ZERO_LOW  = 850     # 0.85 us
ONE_HIGH  = 800     # 0.8 us
ONE_LOW   = 450     # 0.45 us
TOLERANCE = 100     # allow +/- 100 ns

async def read_bit(dut):
    """Wait for a data bit and measure pulse width with Timer for accuracy."""
    # Wait for rising edge of data
    while int(dut.data.value) == 0:
        await Timer(1, units="ns")

    # Measure high time
    high_time = 0
    while int(dut.data.value) == 1:
        await Timer(1, units="ns")
        high_time += 1

    # Measure low time (optional)
    low_time = 0
    while int(dut.data.value) == 0:
        await Timer(1, units="ns")
        low_time += 1

    # Decode bit
    if abs(high_time - ZERO_HIGH) <= TOLERANCE:
        return 0
    elif abs(high_time - ONE_HIGH) <= TOLERANCE:
        return 1
    else:
        raise ValueError(f"Unexpected high pulse width {high_time} ns")

@cocotb.test()
async def test_project(dut):
    # Start the 20 ns clock
    cocotb.start_soon(Clock(dut.clk, 20, unit="ns").start())
    await Timer(50, units="ns")  # let signals settle

    for color_code, expected_bits in [("01", RED), ("10", YELLOW), ("11", BLUE)]:
        dut.color.value = color_code
        dut.rdy.value = 0
        bits_received = []

        for _ in range(24):
            bit = await read_bit(dut)
            bits_received.append(bit)

        for i, bit in enumerate(expected_bits):
            assert bits_received[i] == bit, f"Mismatch at bit {i} for color {color_code}: expected {bit}, got {bits_received[i]}"

        dut._log.info(f"Color {color_code} output matched expected sequence.")

    # Color "00"
    dut.color.value = "00"
    dut.rdy.value = 0
    bits_received = []
    for _ in range(24):
        bit = await read_bit(dut)
        bits_received.append(bit)

    assert all(b == 0 for b in bits_received), f"Expected all zeros for color '00', got {bits_received}"
    dut._log.info("Color '00' output matched expected zeros sequence.")