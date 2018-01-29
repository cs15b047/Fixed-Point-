package Add;

import Def :: * ;

interface Add_IFC;
   method Action  put (DFX#(P0,P1) x , DFX#(P0,P1) y);   
   method ActionValue#(DFX#(P0,P1)) get() ;
endinterface

(* synthesize  *)
module mkAdd(Add_IFC);

	Reg#(DFX#(P0,P1)) v1 <- mkRegU ;
	Reg#(DFX#(P0,P1)) v2 <- mkRegU ;
	Reg#(DFX#(P0,P1)) result <- mkRegU ;
	Reg#(Bool) recv <- mkReg(False) ;
	Reg#(Bool) proc <- mkReg(False) ;
	Reg#(Bit#(1)) temp <- mkRegU ;

rule rl_add(recv == True && proc == False);
	let num1 = v1;let num2 = v2 ;

	int n = fromInteger(valueof(N)) ;
	int p0 = fromInteger(valueof(P0)) ;
	int p1 = fromInteger(valueof(P1)) ;


	//Range Detection
	if(num1.point == 1)
	begin
		Bit#(1) t1 = 1 ;
		Bit#(1) t2 = 1 ;
		for(int j = 1;j <= p0 - p1 + 1 ;j = j + 1)	
		begin			
			t1 = t1 & num1.v[n-j-1] ;				
			t2 = t2 & (~num1.v[n-j-1]) ;
		end

		Bit#(1) t3 = ~(t1 + t2 )  ;
		if(t3 == 0)
		begin
			num1.v = num1.v << (p0 - p1) ;
			num1.point = 0 ;			
		end	
	end

	if(num2.point == 1)
	begin
		Bit#(1) t1 = 1 ;
		Bit#(1) t2 = 1 ;
		for(int j = 1;j <= p0 - p1 + 1 ;j = j + 1)	
		begin			
			t1 = t1 & num2.v[n-j-1] ;				
			t2 = t2 & (~num2.v[n-j-1]) ;
		end

		Bit#(1) t3 = ~(t1 + t2 )  ;
		if(t3 == 0)
		begin
			num2.v = num2.v << (p0 - p1) ;
			num2.point = 0 ;			
		end	
	end

	

	if(num1.point != num2.point)
	begin
		if(num1.point == 0)
		begin
			Bit#(TAdd#(N,TSub#(P0,P1))) temp ;
			temp=signExtend(num1.v);
			temp = temp >> (p0-p1) ;
			num1.v=truncate(temp);
			num1.point = 1 ;
		end
		else
		begin
			Bit#(TAdd#(N,TSub#(P0,P1))) temp ;
			temp=signExtend(num2.v);
			temp = temp >> (p0-p1) ;
			num2.v = truncate(temp);
			num2.point = 1 ;
		end
	end



	Bit#(TAdd#(N,TSub#(P0,P1))) res ;
	Bit#(N) ext1 = signExtend(num1.v) ;
	Bit#(N) ext2 = signExtend(num2.v) ;

	Bit#(N) c = ext1 + ext2 ;
	res = signExtend(c) ;

	temp <= num1.point | num2.point ;

	let overflow = (num1.v[n-2] & num2.v[n-2] & (~res[n-2])) | ((~num1.v[n-2]) & (~num2.v[n-2]) & res[n-2]) ;
	let exp = num1.point | num2.point ;

	let ans_p = num1.point;

	if(exp == 0 && overflow == 1)
		begin
			res = res >> (p0 - p1) ;
			ans_p = 1;
		end

	if(exp == 1 && overflow == 0)
	begin
		Bit#(1) t1 = 1 ;
		Bit#(1) t2 = 1 ;
		for(int j = 1;j <= p0 - p1 + 2 ;j = j + 1)	
		begin			
			t1 = t1 & res[n-j] ;				
			t2 = t2 & (~res[n-j]) ;
		end

		Bit#(1) t3 = ~(t1 + t2 )  ;
		if(t3 == 0)
			begin
				res = res << (p0 - p1) ;
				ans_p= 0;
			end
	end

	// if(exp == 1 && overflow == 1)
	// begin
	// 	$display("overflow_add") ;
	// end

	Bit#(TSub#(N,1)) ans =truncate(res) ;
	DFX#(P0,P1) a;
	a.v = ans ;
	a.point = ans_p ;
	result <= a ;

	// if(!(exp ==1 && overflow == 1))
	// begin
	// 	$display("%d %d",a.v,a.point) ;		
	// end
	recv <= False ;
	proc <= True ;
endrule

method ActionValue#(DFX#(P0,P1)) get() if(proc == True);
	return result ;
endmethod


method Action  put (DFX#(P0,P1) x , DFX#(P0,P1) y ) if(recv == False);   
	v1 <= x; v2 <= y ;recv <= True ;
endmethod


endmodule

endpackage