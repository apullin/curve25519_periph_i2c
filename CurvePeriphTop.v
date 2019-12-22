module CurvePeriphTop
(
    sda, scl, done,
    clk, reset
);

// I2C inputs
input sda;
input scl;

// done INT output
output done;

// TODO: We should actually use a clock generator here, instead of an input clock
input clk;
input reset;

// I2C comment connections
// TODO: Can we do wiring by connecting to named instances directly?
wire [7:0] i2c_subaddr_7_0_out;
wire [7:0] i2c_wr_bus_7_0_out;
wire       i2c_wr_pulse;
wire [7:0] i2c_rd_bus_7_0_in;
wire       i2c_rd_pulse;

// Instantiate our I2C slave controller
I2Cslave i2c_ctrl(
    // I2C bus signals
    .sda_io(sda),
    .scl_in(scl),
    // Other external signals
    .clk_in(clk),
    .clr_in(reset),

    // internal connections, i2c controller <-> curve25519
    .subaddr_7_0_out(i2c_subaddr_7_0_out),
    .wr_bus_7_0_out(i2c_wr_bus_7_0_out),
    .wr_pulse_out(i2c_wr_pulse),
    .rd_bus_7_0_in(i2c_rd_bus_7_0_in),
    .rd_pulse_out(i2c_rd_pulse)
);

// Instantiate our internal register set
// TODO: should we just declare these and all the logic here??
CurvePeriph curve_periph(
    // internal connections, i2c controller <-> curve25519
    .subaddr_7_0_out(   i2c_subaddr_7_0_out ),
    .wr_bus_7_0_out(    i2c_wr_bus_7_0_out  ),
    .wr_pulse(          i2c_wr_pulse        ),
    .rd_bus_7_0_in(     i2c_rd_bus_7_0_in   ),
    .rd_pulse(          i2c_rd_pulse        ),

    // done INT output
    .done(done),

    // required
    .clk(clk),
    .reset(reset)
);

// TODO: Anything to assign here? Or is just connections?

endmodule //CurvePeriphTop