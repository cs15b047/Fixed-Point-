#include <iostream>
#include <sstream>
#include <fstream>
#include <math.h>
#include <bits/stdc++.h>

#define N 32
#define P0 16
#define P1 10
#define threshold pow(2,-P1)

using namespace std;

double convert_DFX_to_float(int num, int point)
{
	double answer ;
	if(num >= (int)pow(2,N-2))
		answer = -((int)pow(2,N-1) - num) ;
	else answer = num ;
	answer = answer / pow(2,(point == 0)?P0:P1) ;

	return answer ;
}


int main()
{
	ifstream fp,fp1;
	fp.open("ip.txt") ;
	fp1.open("op.txt") ;
	string str_o1,str_o2,str1,str2,str3,str4 ;

	int num1, num2,res;
	int pt1,pt2,pt_res ;
	double n1,n2,ans1,ans2=1;

	while(fp>>str1 && fp1>>str_o1)
	{
		fp>>str2;fp>>str3;fp>>str4;	

		stringstream s1,s2,s3,s4 ;
		s1<<hex<<str1; s2<<str2; s3<<hex<<str3; s4<<str4;
		s1>>num1; s2>>pt1; s3>>num2; s4>>pt2 ;

		if(str_o1 != "overflow_mult")
		{
			fp1>>str_o2 ;
			stringstream s,t;
			t<<str_o1; t>>res;
			s<<str_o2;
			s>>pt_res ;
			ans2 = convert_DFX_to_float(res,pt_res) ;
		}

		n1 = convert_DFX_to_float(num1,pt1) ;
		n2 = convert_DFX_to_float(num2,pt2) ;

		ans1 = n1*n2 ;

		if(fabs(ans1) >= pow(2,N-2-P1) && str_o1 == "overflow_mult")
			cout <<"Match & overflow_mult"<<endl ;
		else if(fabs(ans1-ans2) <= threshold && str_o1 != "overflow_mult")
			cout <<"Match with result :"<<" "<<ans1<<endl ;
		else
			cout<<ans1<<" "<<ans2 <<"Mismatch"<<endl;
	}
	
	return 0;
}