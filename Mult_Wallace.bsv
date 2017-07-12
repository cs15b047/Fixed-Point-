package Mult_Wallace;

import Def :: * ;
import Vector :: *;
import FIFOF  :: *;

interface Mult_Wallace_IFC;
   method Action  put (Bit#(TMul#(2, N)) x , Bit#(TMul#(2, N)) y);  
   method ActionValue#(Bit#(TMul#(2, N))) get() ; 
endinterface

typedef struct 
{
	Bit#(TMul#(2,N)) ip1;Bit#(TMul#(2,N)) ip2;Bit#(TMul#(2,N)) ip3;  
	Bit#(TMul#(2,N)) op1;Bit#(TMul#(2,N)) op2;
}CSA
deriving(Bits);


module mkMult_Wallace(Mult_Wallace_IFC);

Reg#(Bit#(TMul#(2, N))) num1 <- mkReg(0);
Reg#(Bit#(TMul#(2, N))) num2 <- mkReg(0);
FIFOF#(Bit#(TMul#(2, N))) ans <- mkFIFOF;
Reg#(Bool) recv <- mkReg(False) ;
Reg#(Vector#(N,Bit#(TMul#(2,N)))) rg_pp <- mkRegU ;
Reg#(int) state <- mkReg(0) ;
Reg#(Vector#(TMul#(2,TLog#(N)),Vector#(TDiv#(N,3),CSA))) rg_level <- mkRegU ;

rule rl_compute_pp(recv == True && state == 0) ;
	Vector#(N,Bit#(TMul#(2,N))) pp ;
	for(Integer i = 0;i < valueof(N) ;i = i + 1)
	begin
		pp[i] = (num2[i] == 1)?(num1 << i ):(0) ;
	end
	rg_pp <= pp ;

	state <= 1 ;
endrule

rule rl_tree_add(recv == True && state == 1);
	Vector#(TMul#(2,TLog#(N)),Vector#(TDiv#(N,3),CSA)) lvl = rg_level;        // change size of outer vector to logN
	Vector#(TMul#(2,TLog#(N)),Vector#(N,Bit#(TMul#(2,N)))) pp_o = replicate(replicate(0))  ;  // change size of outer vector to logN

	pp_o[0] = rg_pp ; // initialize 1st layer of partial products

	Integer size = valueof(N) - 1 ;
	Integer depth = 0;
	for(size = valueof(N) - 1;size > 2;depth = depth + 1)
	begin
		//take ip into CSA		
			Integer j = 0 ;
			for(Integer i =0;i < (size/3) ;i = i + 1)
			begin
				lvl[depth][i].ip1 = pp_o[depth][3*i]; 
				lvl[depth][i].ip2 = pp_o[depth][3*i+1]; 
				lvl[depth][i].ip3 = pp_o[depth][3*i+2];
				lvl[depth][i].op1 = lvl[depth][i].ip1 ^ lvl[depth][i].ip2 ^ lvl[depth][i].ip3 ; // Sum
				lvl[depth][i].op2 = ((lvl[depth][i].ip1 & lvl[depth][i].ip2) | (lvl[depth][i].ip3 & lvl[depth][i].ip2) | (lvl[depth][i].ip1 & lvl[depth][i].ip3)) << 1 ; //Carry
				pp_o[depth + 1][j] = lvl[depth][i].op1;
				pp_o[depth + 1][j+1] = lvl[depth][i].op2 ;
				j = j + 2 ;
			end

		// Account for N not being multiple of 3  and put those inputs to next levl
			if(size - 3*(size/3) == 1)
			begin
				pp_o[depth+1][j] = pp_o[depth][size-1] ;
				j = j + 1 ;
			end
			if(size - 3*(size/3) == 2)
			begin
				pp_o[depth + 1][j] = pp_o[depth][size-2] ;
				pp_o[depth + 1][j+1] = pp_o[depth][size-1] ;
				j = j + 2 ;
			end
			size = j ;
	end	

	// for(Integer i = 0;i < valueof(N);i = i + 1)
	// begin
	// 	$display("%d",pp_o[1][i]) ;
	// end

	ans.enq(pp_o[depth][0] + pp_o[depth][1])  ;
	state <= 2 ;
	
endrule


method ActionValue#(Bit#(TMul#(2, N))) get() if(state == 2) ;	
	recv <= False ;
	ans.deq ;
	return ans.first ;
endmethod


method Action  put (Bit#(TMul#(2, N)) x , Bit#(TMul#(2, N)) y) if(recv == False) ;   
	num1 <= x ; num2 <= y ; recv <= True ; state <= 0 ;
endmethod


endmodule
endpackage

