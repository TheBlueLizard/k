// Copyright (c) K Team. All Rights Reserved.

requires "../map-tests.k"

module ASSIGNMENT-18-SPEC
    imports MAP-TESTS

    claim <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) => . </k> requires Y ==K X andBool Z  ==K Y andBool Z  ==K X andBool X in_keys(MAP)

endmodule
