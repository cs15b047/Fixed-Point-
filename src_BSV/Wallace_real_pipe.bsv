package Wallace_real_pipe;

import Def :: * ;
import Vector :: *;
import FIFOF  :: *;
import Utils :: * ;

interface Wallace_real_pipe_IFC;
   method Action  put (Bit#(TMul#(2, N)) x , Bit#(TMul#(2, N)) y);  
   method ActionValue#(Bit#(TMul#(2, N))) get() ; 
endinterface

typedef struct 
{
	Bit#(TMul#(2,N)) ip1;Bit#(TMul#(2,N)) ip2;Bit#(TMul#(2,N)) ip3;  
	Bit#(TMul#(2,N)) op1;Bit#(TMul#(2,N)) op2;
}CSA
deriving(Bits);

(* synthesize *)
module mkWallace_real_pipe(Wallace_real_pipe_IFC);

Vector#(TMul#(2,TLog#(N)),Reg#(Vector#(N,Bit#(TMul#(2,N))))) pipe <- replicateM(mkRegU) ;
// Reg#(Bit#(TMul#(2,N))) size <- mkReg(fromInteger(valueof(N))) ;
FIFOF#(Bit#(TMul#(2,N))) v1 <- mkFIFOF ;
FIFOF#(Bit#(TMul#(2,N))) v2 <- mkFIFOF ;
FIFOF#(Bit#(TMul#(2,N))) ans <- mkFIFOF ;
Reg#(Bool) flag <- mkReg(False) ;
Reg#(int) rg_dep <- mkReg(0) ;
Vector#(N,Reg#(Bit#(TMul#(2,N)))) num_pp <- replicateM(mkReg(0)) ; 

rule rl_compute_depth_once(flag == False);
	Integer j = 0 ;
	Integer sz = valueof(N) ;
	for(j=0;sz >=3;j = j + 1)
	begin
		// $display("%d",sz) ;
		num_pp[j] <= fromInteger(sz)  ;
		sz = sz - (sz/3) ;
	end
	// $display("%d",sz) ;
	num_pp[j] <= fromInteger(sz)  ;
	rg_dep <= fromInteger(j) ;
	flag <= True ;
	// $display("%0d yo_compute_depth",cur_cycle);
endrule

rule rl_compute_pp;
	let num1 = v1.first; v1.deq; 
	let num2 = v2.first; v2.deq; 

	Vector#(N,Bit#(TMul#(2,N))) temp ;
	Bit#(TMul#(2,N)) t = num1;
	for(Integer i=0;i<valueof(N);i = i + 1)
	begin
		temp[i] = (num2[i]==1)?(t):(0) ;
		t = t << 1 ;
	end
	pipe[0] <= (temp) ;
	// $display("%0d yo_compute_pp",cur_cycle);
endrule


for(Integer depth = 0;depth < valueof(TMul#(2,TLog#(N)))-1;depth = depth + 1)
begin
rule rl_test_depth(flag == True) ;

	Vector#(N,Bit#(TMul#(2,N))) temp_vec = pipe[depth] ;
	Vector#(N,Bit#(TMul#(2,N))) temp_vec2 = replicate(0) ;

	if(fromInteger(depth) == 8)
	begin
		let result = temp_vec[0] + temp_vec[1] ;
		ans.enq(result) ;
	end

	else
	begin
		let size = num_pp[depth] ;
		let size_by_3 = size/3 ;
		Integer j=0;
		for(Integer i =0;i < (valueof(N)-depth)/3;i = i + 3,j=j+2)
		begin
			if(fromInteger(i) < size_by_3)
			begin
				CSA temp ;
				temp.ip1 = temp_vec[i] ; 			
				temp.ip2 = temp_vec[i+1] ; 
				temp.ip3 = temp_vec[i+2] ; 
				temp.op1 = temp.ip1 ^ temp.ip2 ^ temp.ip3 ;
				temp.op2 = ((temp.ip1 & temp.ip2) | (temp.ip2 & temp.ip3) | (temp.ip1 & temp.ip3)) << 1 ;
				temp_vec2[j] = temp.op1 ;
				temp_vec2[j+1] = temp.op2 ;
			end		
		end

		let size_by_3_into_2  = size_by_3 + size_by_3;
		let size_by_3_into_3 = size_by_3_into_2 + size_by_3 ;


		if(size - size_by_3_into_3 == 1)
		begin
			temp_vec2[size_by_3_into_2] = temp_vec[size-1] ;
		end
		if(size - size_by_3_into_3 == 2)
		begin
			let t1 = temp_vec[size-2] ;
			let t2 = temp_vec[size-1] ;
			temp_vec2[size_by_3_into_2] = temp_vec[size-2] ; 
			temp_vec2[size_by_3_into_2+1] = temp_vec[size-1] ;
		end
	end

	// pipe[depth].deq ;
	pipe[depth+1] <= (temp_vec2) ;

	// $display("%0d yo%d",cur_cycle,depth);
endrule
end


method ActionValue#(Bit#(TMul#(2, N))) get() if((flag == True)) ; 
	let result = ans.first ;
	ans.deq ;
	// $display("%0d yo_get",cur_cycle);
	return result ;
endmethod


method Action  put (Bit#(TMul#(2, N)) x , Bit#(TMul#(2, N)) y);
	v1.enq(x);v2.enq(y) ;
	// $display("%0d yo_put",cur_cycle);
endmethod

endmodule
endpackage

