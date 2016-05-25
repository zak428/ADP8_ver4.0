/*********************************************
 * OPL 12.5 Model
 * Author: uchida
 * Creation Date: 2015/12/15 at 17:36:23
 *********************************************/

int H=...;
int P=...;
int Y=...;
int EY=...;
int W=...;
int M=...;
int N=...;
int L=...;
int SN=...;
float R=...;
range PR=0..P-1;
range HR=0..H-1;
range WR=0..W-1;
range MR=0..M-1;
range NR=0..N-1;
float Load[HR]=...;
float MaxLoad=...;
float PFC[PR]=...;
float PVC[PR]=...;
float UP[PR]=...;
float Smin[PR]=...;
float TP[0..W*(Y+1)-1][WR]=...;
int TS[MR]=...;
float GSS[MR][NR]=...;


tuple DATA1{
int H; 
int EY;
int P;
float RR;
float MAX;
int Y;
int W;
int M;
int N;
int L;
int SN;  
}

{DATA1} data1={<H,EY,P,R,MaxLoad,Y,W,M,N,L,SN>};

tuple DATA2{
int i;
float PFC;
float PVC;
float UP;
float Smin;
}

{DATA2} data2={<i,PFC[i],PVC[i],UP[i],Smin[i]>|i in PR};

tuple DATATP{
int c;
int w;
float value;  
}

tuple DATAGSS{
int m;
int n;
float value;  
}

tuple DATATS{
int h;
float value;  
}

tuple DATALoad{
int m;
float value;  
}

{DATALoad} data_Load={<h,Load[h]>|h in HR};
{DATATP} data_TP={<c,w,TP[c][w]>|c in (0..W*(Y+1)-1),w in WR};
{DATATS} data_TS={<m,TS[m]>|m in MR};
{DATAGSS} data_GSS={<m,n,GSS[m][n]>|m in MR,n in NR};

execute fin{
  writeln("Success.");
  }