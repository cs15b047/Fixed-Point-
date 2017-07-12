package Mult_Op;

import Def :: * ;
import Vector :: *;
import FIFOF  :: *;

interface Mult_Op_IFC;
   method Action  put (Bit#(TMul#(2, TSub#(N,1))) x , Bit#(TMul#(2, TSub#(N,1))) y);  
   method ActionValue#(Bit#(TMul#(2, TSub#(N,1)))) get() ; 
endinterface


module mkMult_Op(Mult_Op_IFC);

Vector#(N ,FIFOF#(Bit#(TMul#(2, TSub#(N,1))))) pipeline_num1 <- replicateM(mkFIFOF) ;
Vector#(N ,FIFOF#(Bit#(TMul#(2, TSub#(N,1))))) pipeline_num2 <- replicateM(mkFIFOF) ;
Vector#(N ,FIFOF#(Bit#(TMul#(2, TSub#(N,1))))) pipeline_ans <- replicateM(mkFIFOF) ;

for(int i = 0;i <= fromInteger(valueof(N))-2;i = i + 1)
	rule rl_multiply_i ;
		if(pipeline_num2[i].first[0] == 1)
		begin
			pipeline_ans[i+1].enq(pipeline_ans[i].first + pipeline_num1[i].first)  ;
		end
		else
		begin
			pipeline_ans[i+1].enq(pipeline_ans[i].first)  ;
		end
		pipeline_num2[i+1].enq(pipeline_num2[i].first >> 1) ;
		pipeline_num1[i+1].enq(pipeline_num1[i].first << 1) ;

		pipeline_num1[i].deq; pipeline_num2[i].deq; pipeline_ans[i].deq;		
	endrule

method ActionValue#(Bit#(TMul#(2, TSub#(N,1)))) get() ;
	int n = fromInteger(valueof(N)) ;
	pipeline_num1[n-1].deq; pipeline_num2[n-1].deq; pipeline_ans[n-1].deq;
	return pipeline_ans[n-1].first ;
endmethod


method Action  put (Bit#(TMul#(2, TSub#(N,1))) x , Bit#(TMul#(2, TSub#(N,1))) y) ;   
	pipeline_num1[0].enq(x) ; pipeline_num2[0].enq(y) ;	pipeline_ans[0].enq(0) ;
endmethod

endmodule
endpackage