/*********************************************
 * OPL 12.5 Model
 * Author: uchida
 * Creation Date: 2015/03/03
 *********************************************/

tuple DATA_p1{//one param
int p1;
float value;  
}

tuple DATA_p2{//two param
int p1;
int p2;
float value;  
}

{DATA_p1} dataPFC=...;
{DATA_p1} dataPVC=...;
{DATA_p1} dataUP=...;
{DATA_p1} dataKPmin=...;
{DATA_p1} dataLoad=...;
{DATA_p2} dataTP=...;
{DATA_p1} dataTS=...;
{DATA_p2} dataGSS=...;

{int} dataH=...;
{int} dataEY=...;
{int} dataP=...;
{float} dataRR=...;
{float} dataMAX=...;
{int} dataY=...;
{int} dataW=...;
{int} dataM=...;
{int} dataN=...;
{int} dataL=...;
{int} dataSN=...;

int H = item(dataH,0);
int P= item(dataP,0);
int Y= item(dataY,0);
int YS=0;
int YE=YS+Y-1;
int EY= item(dataEY,0);
int W= item(dataW,0);
int M= item(dataM,0);
int N= item(dataN,0);
int L= item(dataL,0);
int SN= item(dataSN,0);
float R= item(dataRR,0);
range PR=0..P-1;
range HR=0..H-1;
range YR0=YS..YE+1;
range YR=YS..YE;
range YR1=YS+1..YE+1;
range WR=0..W-1;
range MR=0..M-1;
range NR=0..N-1;
range LR=0..L-1;
range WYR=0..W*(Y+1)-1;

float Load[HR];
float MaxLoad= item(dataMAX,0);
float PFC[PR];
float PVC[PR];
float UP[PR];
float Smin[PR];
float TP[WYR][WR];
int WY[YS-1..YE+1];
int TS[MR];
float GSS[MR][NR];

DATA_p1 pfc[PR] = [v.p1:v|v in dataPFC];
DATA_p1 pvc[PR] = [v.p1:v|v in dataPVC];
DATA_p1 up[PR] = [v.p1:v|v in dataUP];
DATA_p1 smin[PR] = [v.p1:v|v in dataKPmin];
DATA_p1 load[HR] = [v.p1:v|v in dataLoad];
DATA_p1 ts[MR] = [v.p1:v|v in dataTS];
DATA_p2 tp[WYR][WR] = [v.p1:[v.p2:v]|v in dataTP];
DATA_p2 gss[MR][NR] = [v.p1:[v.p2:v]|v in dataGSS];


execute init{
  var i,h,m,n,c,w;
  for(i in PR){
    PFC[i]=pfc[i].value;
    PVC[i]=pvc[i].value;
    UP[i]=up[i].value;
    Smin[i]=smin[i].value;
  }
  for(h in HR){
    Load[h]=load[h].value;
  }
  for(m in MR){
   TS[m]=ts[m].value;
    for(n in NR){
    GSS[m][n]=gss[m][n].value;
    }
  }
  for(c in WYR)for(w in WR){
    TP[c][w]=tp[c][w].value;   
  }   
}


float TRP[YR0][WR][WR];
float GS[WR][NR][YR0];
float S0[PR][YR0];

float DISC[YR];
float PFCY[PR][YR];
int NC;

range KR=0..3;
float S[KR][WR][PR][YR0][LR];
float D[KR][WR][PR][YR0][LR];
float OBJ1[KR][WR][YR0][LR];
float OBJ2[KR][WR][YR0][LR];
float SMAX[w in WR][i in PR][y in YS-1..YE+1]=1000;
float SMIN[w in WR][i in PR][y in YS-1..YE+1]=10;
float SMAX2[WR][PR][YR0];
float SMIN2[WR][PR][YR0];
float S_init[PR];
float BigM=1.e7;
float DMAX=5.*BigM;
float AA[WR][PR];
float AA2[WR][PR];
float BB[WR][PR];
float CC[WR];
int KL[KR][WR][YS-1..YE+1][0..SN-1];
int LL[KR][WR][YR0];
int NL[KR][WR][YS-1..YE+1];
int FL[KR][0..1];


execute PreProcess{
	var y,y2,i,j,w,w2,w0,k,v;
	
	for(i in PR){
	  for(y in YR0)S0[i][y]=Smin[i]*(Y-(y-YS))/Y;
 	}	  
	for(i in MR)for(j in NR)GS[WY[YS+TS[i]]++][j][YS+TS[i]]=GSS[i][j];
	NC=1;
	for(y in YR0)NC*=WY[y];
	writeln("NC=",NC);
	WY[YS-1]=1;
	for(w=0;w<WY[YS];w++)TRP[YS][w][0]=TP[w][0];
	for(y in YR1)for(w=0;w<WY[y-1];w++)for(w2=0;w2<WY[y];w2++)TRP[y][w2][w]=TP[w2+W*(y-YS)][w];
	for(y in YR)DISC[y]=Opl.pow(1-R,10*(y-YS));
	for(i in PR)for(y in YR){
	  	PFCY[i][y]=0.
	  	for(y2=y;y2<=YE;y2++)if(y2<y+EY)PFCY[i][y]+=DISC[y2]*PFC[i];
 	}
 	writeln(WY);
 	// S:State Variables, PD:a posteriori D, ED:a priori
 	FL[0][0]=1; //Main Type0 S-PD
 	FL[0][1]=1; //Sub  Type0 PD-S
 	FL[1][0]=0; //Main Type1 PD-S
 	FL[1][1]=1; //Sub  Type1 S-PD
 	FL[2][0]=0; //Main Type2 AD-S
 	FL[2][1]=1; //Sub  Type2 S-AD
 	FL[3][0]=0; //Main Type3 S-AD
 	FL[3][1]=1; //Sub  Type3 AD-S
 	for(i in KR)if(FL[i][0]==0)FL[i][1]=0;
 	
	for(y in YR0){
		for(w=0;w<WY[y];w++){
		  	for(i in PR)S[0][w][i][y][0]=0.5*(SMIN[w][i][y]+SMAX[w][i][y]);
			for(i in PR)S[3][w][i][y][0]=0.5*(SMIN[w][i][y]+SMAX[w][i][y]);
 	  	  	for(i in KR){
 	  	  		KL[i][w][y][0]=0;
 	  	  		LL[i][w][y]=1;
 	  	  		NL[i][w][y]=1;
      		} 	  	  	
     	} 	  	  
   	}
   	for(i in KR)KL[i][0][YS-1][0]=0;
   	for(i in KR)NL[i][0][YS-1]=1;
	for(i in PR)S_init[i]=10;
	
 /* Boundaries of State Variables */
	for(y in YR)for(w0=0;w0<WY[y];w0++){
	  	for(i in PR){
	  	  	v=1.e30;
	   		for(w=0;w<WY[y+1];w++)if(TRP[y+1][w][w0]>0&&v>SMAX[w][i][y+1])v=SMAX[w][i][y+1];
	   	    SMAX2[w0][i][y]=v;
	   	    v=0;
	 		for(w=0;w<WY[y+1];w++)if(TRP[y+1][w][w0]>0&&v<SMIN[w][i][y+1])v=SMIN[w][i][y+1];
	   	    SMIN2[w0][i][y]=v;
       	}	 	   	    
	}
 /*Coefficients of Terminal Function */
	for(w=0;w<WY[YE+1];w++){
	  	for(i in PR){
	    	AA[w][i]=0;
	    	if(AA[w][i]!=0)AA2[w][i]=1/AA[w][i];
	    	else AA2[w][i]=0;
	    	BB[w][i]=0.5*(SMIN[w][i][YE+1]+SMAX[w][i][YE+1]);
 		}	  
    	CC[w]=0.;
	}
 }