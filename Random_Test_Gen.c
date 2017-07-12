#include <stdio.h>
#include <time.h>
#include <math.h>

int main(int argc, char const *argv[])
{
	int tests,N,i;
	scanf("%d%d",&tests,&N);

	FILE *fp = fopen("ip.txt","w") ;
	time_t t ;
	srand((unsigned) time(&t)) ;
	int len = (int)pow(2,N-10) ;

	for(i=0;i<tests;i++)
		fprintf(fp,"%08x\n%08x\n%08x\n%08x\n", rand() % len, rand() % 2, rand() % len, rand() % 2 ) ;

	fclose(fp) ;


	return 0;
}