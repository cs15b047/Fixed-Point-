package Mult ;

import Def :: * ;
import Wallace_real_pipe:: * ;
import FIFOF :: * ;
import Utils :: * ;

interface Mult_IFC;
   method Action  put (DFX#(P0,P1) x , DFX#(P0,P1) y);
   method ActionValue#(DFX#(P0,P1))  get ();   
endinterface

(*synthesize*)
module mkMult(Mult_IFC) ;

FIFOF#(DFX#(P0,P1)) v1 <- mkSizedFIFOF(15) ;
FIFOF#(DFX#(P0,P1)) v2 <-mkSizedFIFOF(15) ;
FIFOF#(Bit#(1)) s1 <-mkSizedFIFOF(15) ;
FIFOF#(Bit#(1)) s2 <-mkSizedFIFOF(15) ;
FIFOF#(int) dec_pt <- mkSizedFIFOF(15);
FIFOF#(DFX#(P0,P1)) result <- mkSizedFIFOF(15);

Wallace_real_pipe_IFC handle <- mkWallace_real_pipe;

rule rl_mult_1 ;
	let num1 = v1.first; v1.deq ;
	let num2 = v2.first; v2.deq ;	
	int n = fromInteger(valueof(N)) ;
	int p0 = fromInteger(valueof(P0)) ;
	int p1 = fromInteger(valueof(P1)) ;
	int d = 0 ; // represents location of decimal point
	Bit#(1) sign1 = 0 ;
	Bit#(1) sign2 = 0 ;	

	//decide point location
		if(num1.point == 0)
			d = p0 ;
		else 
			d = p1 ;
		if(num2.point == 0)
			d = d + p0 ;
		else 
			d = d + p1 ;	
		dec_pt.enq(d)  ;

	//find sign and take abs value of nos.
		if(num1.v[n-2] == 1)
		begin
			sign1 = 1 ;
			num1.v = (~num1.v) + 1 ;
		end
		if(num2.v[n-2] == 1)
		begin
			sign2 = 1 ;
			num2.v = (~num2.v) + 1 ;
		end	
		s1.enq(sign1) ;s2.enq(sign2) ;


	Bit#(TMul#(2, N)) ext1 = extend(num1.v) ;
	Bit#(TMul#(2, N)) ext2 = extend(num2.v) ;

	// $display("%0d yo1",cur_cycle);

	handle.put(ext1,ext2) ;
endrule

rule rl_mult_2 ;
	let ans <- handle.get() ;
	// $display("%0d yo_recv",cur_cycle);

	int n = fromInteger(valueof(N)) ;
	int p0 = fromInteger(valueof(P0)) ;
	int p1 = fromInteger(valueof(P1)) ;
	int d = dec_pt.first ; dec_pt.deq ;
	int loc_ov = d + n - 2 -p1 ;
	int loc0 = d + n - 2 - p0 ;
	int size = 2*(n-1) ;
	int y = -1;

	Bit#(1) sign1 = s1.first ; s1.deq ;
	Bit#(1) sign2 = s2.first ; s2.deq ;
	
	// Stores answer and point location
	Bit#(TSub#(N,1)) res = 0;
	Bit#(1) pt = 0;

	//check output range
		//overflow
		let check_of = ans >> (loc_ov);
		if(check_of != 0 )
		begin
			y = 2 ;
		end

		// belongs to p0
		let check_0 = ans >> loc0 ;
		if(check_0 == 0)
		begin
			y = 0 ;
		end

		//else to p1
		if(y == -1)
		begin
			y = 1 ;
		end

	let rang = y ;

	//shift result according to range

		if(rang == 2)
		begin
			$display("overflow_mult") ;
		end
	
		if(rang == 1)
		begin
			let x = ans >> (d - p1) ; 
			res = truncate(x) ;
			pt = 1 ;
		end
		if(rang == 0)
		begin
			let x = ans >> (d - p0) ;
			res = truncate(x) ;
			pt = 0 ;
		end
		//give proper sign
		if((sign1^sign2) == 1)
			res = (~res) + 1 ;

	if(rang != 2)
	begin
		$display("%d %d",res,pt) ;
	end

	DFX#(P0,P1) tmp ;
	tmp.v = res;tmp.point = pt ;
	result.enq(tmp) ;

endrule

method ActionValue#(DFX#(P0,P1)) get ();   
	result.deq ;
	return result.first ;
endmethod


method Action  put (DFX#(P0,P1) x , DFX#(P0,P1) y ) ;   
	v1.enq(x); v2.enq(y);
endmethod

endmodule

endpackage