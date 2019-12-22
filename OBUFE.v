module OBUFE
(
    I, E, O
);

input I;
input E;

output O;

assign O = E ? I : 1'bz;

endmodule //OBUFE