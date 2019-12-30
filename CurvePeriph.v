module CurvePeriph
(
    // I2C controller interface
    subaddr_7_0_out, wr_bus_7_0_out, wr_pulse, rd_bus_7_0_in, rd_pulse,
    // done INT output
    done_int,
    // Required
    reset, clk
);

// Required
input wire reset;
input wire clk;

// I2CSlave interface:
input wire [7:0] subaddr_7_0_out;
input wire [7:0] wr_bus_7_0_out;
input wire wr_pulse;
output reg [7:0] rd_bus_7_0_in;
input wire rd_pulse;

// signals TO curve25519 core
reg [254:0] n; // scalar
reg [254:0] q; // point
wire start;

// Signals FROM curve25519 core
output wire done_int;
wire [254:0] result_wire;
reg [254:0] result;

// Control Register
// - start bit
// - done bit
// - in-progress bit
// - interrupt enable
// - SW clear/reset
localparam CTRL_START_BIT=0, CTRL_DONE_BIT=1, CTRL_INPROG_BIT=2, CTRL_INTEN_BIT=3, CTRL_SWCLEAR_BIT=4;
reg [7:0] ctrl_reg;

// Instantiate our Cureve25519 calculation core
Curve25519 curve25519_core(
    // required
    .clock(clk),

    // Input and output values
    .n(n), // scalar
    .q(q), // point
    .result(result_wire), //result

    .start(ctrl_reg[CTRL_START_BIT]),
    // done INT output
    .done(done_int)
);

/* Register map
    addr 0x00 to 0x19 --> n
    addr 0x20 to 0x39 --> q
    addr 0x40 to 0x59 --> result
    addr 0x60         --> ctrl_reg
*/

always @(posedge clk)
begin

    if( reset )
    begin
        n = 0; q = 0; result = 0;
    end
    else
    begin
        // On write operation
        if( wr_pulse )
        begin
            if ( (subaddr_7_0_out >= 'h00) && (subaddr_7_0_out < 'h20) )
                n[ subaddr_7_0_out*8 ] = wr_bus_7_0_out;
            else if ( (subaddr_7_0_out >= 'h20) && (subaddr_7_0_out < 'h40) )
                q[ (subaddr_7_0_out-'h20)*8 ] = wr_bus_7_0_out;
            else if ( subaddr_7_0_out == 'h60 )
                ctrl_reg = wr_bus_7_0_out;
        end // wr_pulse

        // on Read operation
        if( rd_pulse )
        begin
            if ( (subaddr_7_0_out >= 'h00) && (subaddr_7_0_out < 'h20) )
                rd_bus_7_0_in = n[ subaddr_7_0_out ];
            else if ( (subaddr_7_0_out >= 'h20) && (subaddr_7_0_out < 'h40) )
                rd_bus_7_0_in = q[ (subaddr_7_0_out-'h20)*8 ];
            else if ( (subaddr_7_0_out >= 'h40) && (subaddr_7_0_out) < 'h60 )
                rd_bus_7_0_in = result[ (subaddr_7_0_out-'h40)*8 ];
            else if ( subaddr_7_0_out == 'h60 )
                rd_bus_7_0_in = ctrl_reg;
        end // rd_pulse

		if( done_int )
			result = result_wire;
    end

    ctrl_reg[CTRL_DONE_BIT] = done_int;


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

end

endmodule //CurvePeriph