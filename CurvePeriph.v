module CurvePeriph
(
    // I2C controller interface
    subaddr_7_0_out, wr_bus_7_0_out, wr_pulse, rd_bus_7_0_in, rd_pulse,
    // done INT output
    done,
    // Required
    input reset, clk
);

// I2CSlave interface:
input wire [7:0] subaddr_7_0_out;
input wire [7:0] wr_bus_7_0_out;
input wire wr_pulse;
input wire [7:0] rd_bus_7_0_in;
input wire rd_pulse;

// signals TO curve25519 core
reg [254:0] n; // scalar
reg [254:0] q; // point

// Signals FROM curve25519 core
output wire done;
reg [254:0] result;

// Control Register
// - start bit
// - done bit
// - in-progress bit
// - interrupt enable
// - SW clear/reset
reg [7:0] ctrl_reg;

// Instantiate our Cureve25519 calculation core
Curve25519 curve25519_core(
    // required
    .clock(clk),

    // Input and output values
    .n(n), // scalar
    .q(q), // point
    .result(result), //result

    // .start is not exposed
    // done INT output
    .done(done)
);

/* Register map
    addr 0x00 to 0x19 --> n
    addr 0x20 to 0x39 --> q
    addr 0x40 to 0x59 --> result
    addr 0x60         --> ctrl_reg
*/

// TODO: implement read/write/lookup/start logic
/*
    on write pulse:
        if subaddr in (0x00, 0x20)
            n[ subaddr ] = wr_bus_7_0_out  //TODO: figure out array access math
        if subaddr in (0x20, 0x40)
            q[ subaddr - 0x20 ] = wr_bus_7_0_out
        if subaddr == 0x60
            ctrl_reg = wr_bus_7_0_out
        else
            non-writable location ; i2c NACK?

    on read pulse:
        if subaddr in (0x00, 0x20)
            rd_bus_7_0_in = n[ subaddr ]
        if subaddr in (0x20, 0x40)
            rd_bus_7_0_in = n[ subaddr - 0x20 ]
        if subaddr in (0x40, 0x60)
            rd_bus_7_0_in = result[ subaddr - 0x40 ]
        if subaddr == 0x60
            rd_bus_7_0_in = ctrl_reg

    always:
        // Start conversion when start bit is written
        // TODO: actually only want this on a rising edge of `start`
        if ctrl_reg[ SW_START_BIT ] == 1
            start = 1
        else
            start = 0

    assign done to ctrl_reg[ DONE_BIT ]
*/

endmodule //CurvePeriph