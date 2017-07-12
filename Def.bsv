package Def ;

import Utils :: *;
import FixedPoint :: * ;

typedef 2000 Tests ;

typedef struct {
	Bit#(TSub#(N,1)) v ;
	Bit#(1) point ;
}DFX#(numeric type x,numeric type y)
deriving(Bits);

//KEEP N >= 10

typedef 32 N ; //Bitwidth
//P0 and P1 are 2 options for position of decimal point
typedef 2 P0 ;  
typedef 1 P1 ;

endpackage
