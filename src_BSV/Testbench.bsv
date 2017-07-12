package Testbench ;

import Add :: * ;
import Mult :: * ;
//import Div :: * ;
// import Sqrt :: * ;
import Def :: * ;
import Real :: * ;
import FixedPoint :: * ;
import RegFile :: * ;

module mkTestbench(Empty) ;
		
	Reg#(Bool) taken <- mkReg(False) ;
	Reg#(Bit#(32)) count <- mkReg(0) ;
	Reg#(DFX#(P0,P1)) r1 <- mkRegU ;
	Reg#(DFX#(P0,P1)) r2 <- mkRegU ;

	RegFile#(Bit#(32),Bit#(32)) file <- mkRegFileFullLoad("ip.txt") ;

	Add_IFC a <- mkAdd ;
	Mult_IFC m <- mkMult ;
	// Div_IFC d <- mkDiv ;
	// Sqrt_IFC s <- mkSqrt ;

	rule rl_take_ip(count < 4*pack(fromInteger(valueof(Tests))));

		DFX#(P0,P1) t1 ;
		DFX#(P0,P1) t2 ;

		t1.v = truncate(pack(file.sub(count))) ;
		t1.point = truncate(pack(file.sub(count+1))) ;
		t2.v = truncate(pack(file.sub(count+2))) ;
		t2.point = truncate(pack(file.sub(count+3))) ;

		r1 <= t1 ;
		r2 <= t2 ;
		//a.put(t1,t2) ;

		m.put(t1,t2) ;
		// d.put(t1,t2) ;
		// s.put(t1,t2) ;

		count <= count + 4 ;
	endrule

	rule rl_get_op;
		let ans <- m.get() ;

		// $display("%d %d",ans.v,ans.point) ;

	endrule

endmodule

endpackage
