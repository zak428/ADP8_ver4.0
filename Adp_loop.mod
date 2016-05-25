/*********************************************
 * OPL 12.5 Model
 * Author: uchida
 * Creation Date: 2015/03/03
 *********************************************/
 

int H=...;//時
int P=...;//発電所の種類の数
int Y=...;//年
int YS=...;//YearStart init.mod参照(デフォルトでは0)
int YE=...;//YearEnd init.mod参照(デフォルトではYS=0よりY-1)
int W=...;//分岐数
int N=...;//不確実性を与える対象の数。今は需要の変動のみなので1
int L=...;//蓄えられるサンプル点の上限
int SN=...;	//Maximum Sample Number

range PR=0..P-1;
range HR=0..H-1;
range YR=YS..YE;
range WR=0..W-1;
range NR=0..N-1;
range LR=0..L-1;
range YR0=YS..YE+1;
range KR=0..3;
range KR0=-1..3;//重複のため除外された点はk=-1

float Load[HR]=...;
float MaxLoad=...;
float PVC[PR]=...;
float UP[PR]=...;
float GS[WR][NR][YR0]=...;
float DISC[YR]=...;
float PFCY[PR][YR]=...;
float S0[PR][YR0]=...;
float SMAX[WR][PR][YR0]=...;
float SMIN[WR][PR][YR0]=...;
float TRP[YR0][WR][WR]=...;
int WY[YR0]=...;
float SMAX2[WR][PR][YR0]=...;
float SMIN2[WR][PR][YR0]=...;
float S_init[PR]=...;
float DMAX=...;
float AA[WR][PR]=...;
float AA2[WR][PR]=...;
float BB[WR][PR]=...;
float CC[WR]=...;

int y=...;
int k;//うまくうごかない

//float S[KR][WR][PR][YR0][LR]=...;//ループ対象変数(SQL格納対象変数)
//float D[KR][WR][PR][YR0][LR]=...;//ループ対象変数(SQL格納対象変数)
//float OBJ1[KR][WR][YR][LR]=...;//ループ対象変数(SQL格納対象変数)
//float OBJ2[KR][WR][YR][LR]=...;//ループ対象変数(SQL格納対象変数)
float BigM=...;

range WR1=0..WY[y]-1;
range WR2=0..WY[y+1]-1;
range SNR=0..SN-1;
range YRU=maxl(YS,y)..minl(y+1,YE+1);//必要部分のみロード
//int KL[KR][WR][YS-1..YE+1][SNR]=...;
int LL[KR][WR][YR0]=...;
int NL[KR][WR][YS-1..YE+1]=...;
int FL[KR][0..1]=...;

  tuple ADP_sample_point {//状態変数ごとに作成
  int k;//計算手法
  int w;//シナリオ番号
  int y;//時点番号
  int l;//サンプル点番号 
  int ss;//状態変数
  float S;//サンプル点
  float D;//傾き
  }

  tuple ADP_New_sample_point {//状態変数ごとに作成
  float S;
  float D;
  }
   
  tuple ADP_sample_L {//KL,NL,LL作成用
  int snr;
  int k;//計算手法
  int w;//シナリオ番号
  int y;//時点番号
  int l;//サンプル点番号 
  int flag;//0:無し　1:未計算　2:計算済み　n(n>=2):n-1回計算済み
  }

  tuple ADP_sample_LL {//KL,NL,LL作成用
  int k;//計算手法
  int w;//シナリオ番号
  int y;//時点番号
  int max_l;//サンプル点番号 
  }
 
tuple OBJ_db {
  int k;//計算手法
  int w;//シナリオ番号
  int y;//時点番号
  int l;//サンプル点番号 
  float obj1;
  float obj2;
  int flag;
  int flag2;
}

/*サンプル点の値の情報*/
{ADP_sample_point} samp_SD = ...;
float S[KR0][WR][PR][YR0][LR] = [v.k:[v.w:[v.ss:[v.y:[v.l:v.S]]]]|v in samp_SD : v.y==maxl(YS,y) || v.y==minl(y+1,YE+1) ];
float D[KR0][WR][PR][YR0][LR] = [v.k:[v.w:[v.ss:[v.y:[v.l:v.D]]]]|v in samp_SD : v.y==maxl(YS,y) || v.y==minl(y+1,YE+1) ];
ADP_New_sample_point SAMPLE_N[KR][WR][PR][YR0][LR];

/*KL,LL,NL格納用*/
{ADP_sample_L} samp_L = ...;//flag==1のみ
{ADP_sample_L} samp_L2 = ...;//flag>=2
{ADP_sample_L} samp_L_y0 = ...;//y=0用
{ADP_sample_LL} samp_LL = ...;//getLL
int KL[KR0][WR][YS-1..YE+1][SNR] = [v.k:[v.w:[v.y:[v.snr-1:v.l]]]|v in samp_L];//flag=1 KL作成用
int KL2[KR0][WR][YS-1..YE+1][SNR] = [v.k:[v.w:[v.y:[v.snr-1:v.l]]]|v in samp_L2];//flag>=2 KL作成用
int KL0[KR0][WR][YS-1..YE+1][0..1] = [v.k:[v.w:[v.y:[v.snr-1:v.l]]]|v in samp_L_y0];//y=0 KL作成用
int LL2[KR0][WR][YR0] = [v.k:[v.w:[v.y:v.max_l]]|v in samp_LL];//LL作成用

int KL_flag[KR0][WR][YS-1..YE+1][SNR] = [v.k:[v.w:[v.y:[v.snr-1:v.flag]]]|v in samp_L];//flag=1 KL作成用 flag
int KL2_flag[KR0][WR][YS-1..YE+1][SNR] = [v.k:[v.w:[v.y:[v.snr-1:v.flag]]]|v in samp_L2];//flag>=2 KL作成用 flag
int KL0_flag[KR0][WR][YS-1..YE+1][0..1] = [v.k:[v.w:[v.y:[v.snr-1:v.flag]]]|v in samp_L_y0];//y=0 KL作成用 flag

/*obj*/
{OBJ_db} obj_db = ...;
float OBJ1[KR0][WR][YR0][LR] = [v.k:[v.w:[v.y:[v.l:v.obj1]]]|v in obj_db : v.y==maxl(YS,y) || v.y==minl(y+1,YE+1) ];
float OBJ2[KR0][WR][YR0][LR] = [v.k:[v.w:[v.y:[v.l:v.obj2]]]|v in obj_db : v.y==maxl(YS,y) || v.y==minl(y+1,YE+1) ];
int flag[KR0][WR][YR0][LR] = [v.k:[v.w:[v.y:[v.l:v.flag]]]|v in obj_db : v.y==maxl(YS,y) || v.y==minl(y+1,YE+1) ];
int flag2[KR0][WR][YR0][LR] = [v.k:[v.w:[v.y:[v.l:v.flag2]]]|v in obj_db : v.y==maxl(YS,y) || v.y==minl(y+1,YE+1) ];

execute pre{

 
  writeln("------------------start pre------------------");
  writeln("generating KL,LL,NL,Sample point data...");

  for(k in KR)for(w in WR)for(yy in YR0){/*NL、KL、LL作成*/
    	NL[k][w][yy]=0;   
 		    //flag=1でSNRが埋まらなかった場合,flag2以上のものを格納しておく。
 		    if(yy != 0){//if文はy=0でのNLのキャリブレーション用
				for(tt in SNR){
				  for(t in SNR){
				  if(KL2_flag[k][w][yy][tt]>=2&&KL_flag[k][w][yy][t]!=1){
				    KL[k][w][yy][t]=KL2[k][w][yy][tt];
				    KL_flag[k][w][yy][t]=KL2_flag[k][w][yy][tt];
				    break;
      				}	
                  }         		        			  			    
                }
            }
            if(yy == YS){//y=0でのKLキャリブレーション用 snr=0でほしい列が取得できる用調整してあります。
              KL[k][w][yy][0] = KL0[k][w][yy][0];
              KL_flag[k][w][yy][0] = KL0_flag[k][w][yy][0];           
            }        		  		      
  		    
  		for(t in SNR){ 		    
  			if(KL_flag[k][w][yy][t]>=1){//KL,NL,LLの計算
    				NL[k][w][yy]++;
    				//write("[SAMP: k="+k+" w="+w+" y="+yy+" sn="+t+"]" );    				
    				if(y==yy){flag[k][w][yy][KL[k][w][yy][t]]++;flag2[k][w][yy][KL[k][w][yy][t]]++;}//計算済み判定 
    				//writeln("<KL:"+KL[k][w][yy][t]+",flag:"+KL_flag[k][w][yy][t]+":"+flag[k][w][yy][KL[k][w][yy][t]]+">");
    		}
    		if(NL[k][w][YE+1]==0){NL[k][w][yy]++;}
      	}
      		if(!(yy==YS&&w!=0))LL2[k][w][yy]++;//if文はy=0、w!=0でのLLのキャリブレーション用
      		if(yy!=YS-1)LL[k][w][yy]=LL2[k][w][yy];//if文はy=YS-1でのLLのキャリブレーション用
      		//if(NL[k][w][yy]>=1)writeln("y:"+yy+" k:"+k+" w:"+w+" NL:"+NL[k][w][yy]+" LL:"+ LL[k][w][yy]);
    }      			  
    writeln("generated KL,LL,NL." );
    
    for(k in KR)for(w in WR)for(yy in YRU){//flagの初期化
      for(l=0;l<LL[k][w][yy];l++){//for(l in LR){//LRの場合だと、現仕様より2分多くかかる
    	if(flag[k][w][yy][l]>=1){
    	}else{
    	   flag[k][w][yy][l]=0;
    	   OBJ1[k][w][yy][l]=0;
    	   	for(i in PR){//初期化
		 		//S[k][w][i][yy][l]=(SMIN[w][i][y]+SMAX[w][i][y])/2;
				//D[k][w][i][yy][l]=0;
			}
    	}    
    		 
    	if(flag2[k][w][yy][l]>=1){
    	}else{
    	   OBJ2[k][w][yy][l]=0;
    	   flag2[k][w][yy][l]=0;
    	}
    }}    
    writeln("generated Sample point data. "+ P +" State variable." );

  writeln("------------------fin pre------------------");
}  

dvar float s1[PR][SNR][WR1];
dvar float s2[PR][SNR][WR1];
dvar float+ z1[PR][SNR][WR1];
dvar float+ z2[PR][SNR][WR1];
dvar float+ x0[PR][SNR][WR1];
dvar float+ x1[HR][PR][SNR][WR1];
dvar float+ x2[PR][SNR][WR1];
dvar float cost1[SNR][WR1];
dvar float vobj1[SNR][WR2][WR1];
dvar float obj1[SNR][WR1];

/*
dvar float sa1[PR][SNR][WR1];
dvar float sa2[PR][SNR][WR1];
dvar float+ za1[PR][SNR][WR1];
dvar float+ za2[PR][SNR][WR1];
dvar float+ zza1[PR][SNR][WR2][WR1];
dvar float+ zza2[PR][SNR][WR2][WR1];
dvar float+ xa0[PR][SNR][WR1];
dvar float+ xa1[HR][PR][SNR][WR1];
dvar float+ xa2[PR][SNR][WR1];
dvar float+ ra[SNR][WR2][WR1][LR];
dvar float cost2[SNR][WR1];
dvar float vobj2[SNR][WR2][WR1];
dvar float obj2[SNR][WR1];
*/

dvar float dd1[PR][SNR][WR1];
dvar float dd2[PR][SNR][WR2][WR1];
dvar float dd0[PR][SNR][WR1];
dvar float yy0[PR][SNR][WR1];
dvar float yy1[HR][SNR][WR1];
dvar float+ yy2[HR][PR][SNR][WR1];
dvar float+ yy3[SNR][WR1];
dvar float cost2[SNR][WR1];
dvar float aux2[SNR][WR1];
dvar float vobj2[SNR][WR2][WR1];
dvar float obj2[SNR][WR1];

dvar float d1[PR][SNR][WR1];
dvar float d0[PR][SNR][WR1];
dvar float d2[PR][SNR][WR2][WR1];
dvar float y0[PR][SNR][WR1];
dvar float y1[HR][SNR][WR1];
dvar float+ y2[HR][PR][SNR][WR1];
dvar float+ y3[SNR][WR1];
dvar float+ y6[PR][SNR][WR1];
dvar float+ y7[PR][SNR][WR1];
dvar float cost3[SNR][WR1];
dvar float aux3[SNR][WR1];
dvar float vobj3[SNR][WR2][WR1];
dvar float obj3[SNR][WR1];

dvar float ss1[PR][SNR][WR1];
dvar float ss2[PR][SNR][WR1];
dvar float+ zz1[PR][SNR][WR1];
dvar float+ zz2[PR][SNR][WR1];
dvar float+ xx0[PR][SNR][WR1];
dvar float+ xx1[HR][PR][SNR][WR1];
dvar float+ xx2[PR][SNR][WR1];
dvar float cost4[SNR][WR1];
dvar float aux4[SNR][WR1];
dvar float vobj4[SNR][WR2][WR1];
dvar float obj4[SNR][WR1];

dvar float de1[PR][SNR][WR2][WR1];
dvar float de0[PR][SNR][WR1];
dvar float de2[PR][SNR][WR2][WR1];
dvar float ye0[PR][SNR][WR2][WR1];
dvar float ye1[HR][SNR][WR2][WR1];
dvar float+ ye2[HR][PR][SNR][WR2][WR1];
dvar float+ ye3[SNR][WR2][WR1];
dvar float+ ye6[PR][SNR][WR1];
dvar float+ ye7[PR][SNR][WR1];
dvar float cost5[SNR][WR2][WR1];
dvar float aux5[SNR][WR1];
dvar float vobj5[SNR][WR2][WR1];
dvar float obj5[SNR][WR1];

dvar float sse1[PR][SNR][WR1];
dvar float sse2[PR][SNR][WR2][WR1];
dvar float+ zze1[PR][SNR][WR2][WR1];
dvar float+ zze2[PR][SNR][WR2][WR1];
dvar float+ xxe0[PR][SNR][WR2][WR1];
dvar float+ xxe1[HR][PR][SNR][WR2][WR1];
dvar float+ xxe2[PR][SNR][WR2][WR1];
dvar float cost6[SNR][WR2][WR1];
dvar float aux6[SNR][WR1];
dvar float vobj6[SNR][WR2][WR1];
dvar float obj6[SNR][WR1];

dvar float se1[PR][SNR][WR1];
dvar float se2[PR][SNR][WR2][WR1];
dvar float+ ze1[PR][SNR][WR2][WR1];
dvar float+ ze2[PR][SNR][WR2][WR1];
dvar float+ xe0[PR][SNR][WR2][WR1];
dvar float+ xe1[HR][PR][SNR][WR2][WR1];
dvar float+ xe2[PR][SNR][WR2][WR1];
dvar float cost7[SNR][WR2][WR1];
dvar float vobj7[SNR][WR2][WR1];
dvar float obj7[SNR][WR1];

dvar float dde1[PR][SNR][WR2][WR1];
dvar float dde0[PR][SNR][WR1];
dvar float dde2[PR][SNR][WR2][WR1];
dvar float yye0[PR][SNR][WR2][WR1];
dvar float yye1[HR][SNR][WR2][WR1];
dvar float+ yye2[HR][PR][SNR][WR2][WR1];
dvar float+ yye3[SNR][WR2][WR1];
dvar float+ yye6[PR][SNR][WR1];
dvar float+ yye7[PR][SNR][WR1];
dvar float cost8[SNR][WR2][WR1];
dvar float aux8[SNR][WR1];
dvar float vobj8[SNR][WR2][WR1];
dvar float obj8[SNR][WR1];

dvar float J1;
dvar float J2;
dvar float J3;
dvar float J4;
dvar float J5;
dvar float J6;
dvar float J7;
dvar float J8;

constraint cts[PR][SNR][WR1];
constraint ctd[PR][SNR][WR1];
constraint cte[PR][SNR][WR1];
constraint cta[PR][SNR][WR1];

minimize  J1-J2-J3+J4-J5+J6+J7-J8;

subject to{
  
  	J1==FL[0][0]*sum(w in WR1,n in 0..NL[0][w][y]-1)obj1[n][w]; //Lower Bound Value
  	J2==FL[0][1]*sum(w in WR1,n in 0..NL[0][w][y]-1)obj2[n][w]; //Upper Bound Value
  	J3==FL[1][0]*sum(w in WR1,n in 0..NL[1][w][y]-1)obj3[n][w];	//Upper Bound Value
  	J4==FL[1][1]*sum(w in WR1,n in 0..NL[1][w][y]-1)obj4[n][w];	//Lower Bound Value
 	J5==FL[2][0]*sum(w in WR1,n in 0..NL[2][w][y]-1)obj5[n][w];	//Upper Bound Value
 	J6==FL[2][1]*sum(w in WR1,n in 0..NL[2][w][y]-1)obj6[n][w];	//Lower Bound Value
 	J7==FL[3][0]*sum(w in WR1,n in 0..NL[3][w][y]-1)obj7[n][w];	//Lower Bound Value
 	J8==FL[3][1]*sum(w in WR1,n in 0..NL[3][w][y]-1)obj8[n][w];	//Upper Bound Value
 		  
/* Cutting Plane Approximation (Outer Linearization) 1 */
if(FL[0][0]==1){
 	forall(w in WR1,n in 0..NL[0][w][y]-1){
	  	forall(i in PR)if(y>=YS)cts[i][n][w]:s1[i][n][w]==S[0][w][i][y][KL[0][w][y][n]];
 	  	if(y<=YE){
 	  		obj1[n][w]==cost1[n][w]+sum(w2 in WR2)TRP[y+1][w2][w]*vobj1[n][w2][w]; 	  	  
			forall(w2 in WR2,k in 0..LL[0][w2][y+1]-1)if(TRP[y+1][w2][w]>0)vobj1[n][w2][w]>=OBJ1[0][w2][y+1][k]+sum(i in PR)D[0][w2][i][y+1][k]*(s2[i][n][w]-S[0][w2][i][y+1][k]);
 	  	  	if(y==YS-1){
 	  	    	cost1[n][w]==0;
				forall(i in PR){
				  	s1[i][n][w]==S_init[i];
					s2[i][n][w]==s1[i][n][w];
   				}					
       		}
       		else{
				cost1[n][w]==sum(i in PR)(PFCY[i][y]*x2[i][n][w]+DISC[y]*PVC[i]*365*sum(h in HR)x1[h][i][n][w])+BigM*sum(i in PR)(z1[i][n][w]+z2[i][n][w]);
				forall(i in PR){
		  			s2[i][n][w]==x2[i][n][w]+s1[i][n][w];
  		  			SMIN2[w][i][y]<=s2[i][n][w]<=SMAX2[w][i][y];
 		  			x0[i][n][w]-z1[i][n][w]+z2[i][n][w]==s1[i][n][w];
		  			forall(h in HR)UP[i]*(S0[i][y]+x0[i][n][w])>=x1[h][i][n][w];
   				}		  	
 				forall(h in HR)sum(i in PR)x1[h][i][n][w]+15==GS[w][0][y]*Load[h];
				sum(i in PR)UP[i]*(S0[i][y]+x0[i][n][w])+15>=(1+0.08)*GS[w][0][y]*MaxLoad;
  			}				
		}
		else obj1[n][w]==CC[w]+sum(i in PR)(0.5*AA[w][i]*(S[0][w][i][y][KL[0][w][y][n]]-BB[w][i])*(S[0][w][i][y][KL[0][w][y][n]]-BB[w][i])
		  		+AA[w][i]*(S[0][w][i][y][KL[0][w][y][n]]-BB[w][i])*(s1[i][n][w]-S[0][w][i][y][KL[0][w][y][n]]));
	}			
}

/*
if(FL[0][1]==1){
 	forall(w in WR1,n in 0..NL[0][w][y]-1){
	  	forall(i in PR)if(y>=YS)sa1[i][n][w]==S[0][w][i][y][KL[0][w][y][n]];
 	  	if(y<=YE){
 	  		obj2[n][w]==cost2[n][w]+sum(w2 in WR2)TRP[y+1][w2][w]*vobj2[n][w2][w]+DMAX*sum(i in PR,w2 in WR2)(zza1[i][n][w2][w]+zza2[i][n][w2][w]); 	  	  
			forall(w2 in WR2)if(TRP[y+1][w2][w]>0){
				vobj2[n][w2][w]==sum(k in 0..LL[0][w2][y+1]-1)ra[n][w2][w][k]*OBJ2[0][w2][y+1][k];
				sum(k in 0..LL[0][w2][y+1]-1)ra[n][w2][w][k]==1;
				forall(i in PR)sa2[i][n][w]==sum(k in 0..LL[0][w2][y+1]-1)ra[n][w2][w][k]*S[0][w2][i][y+1][k]+zza1[i][n][w2][w]-zza2[i][n][w2][w];
  			} 	  	  	
 	  	  	if(y==YS-1){
 	  	    	cost2[n][w]==0;
				forall(i in PR){
				  	sa1[i][n][w]==S_init[i];
					sa2[i][n][w]==sa1[i][n][w];
   				}					
       		}
       		else{
				cost2[n][w]==sum(i in PR)(PFCY[i][y]*xa2[i][n][w]+DISC[y]*PVC[i]*365*sum(h in HR)xa1[h][i][n][w])+BigM*sum(i in PR)(za1[i][n][w]+za2[i][n][w]);
				forall(i in PR){
		  			sa2[i][n][w]==xa2[i][n][w]+sa1[i][n][w];
  		  			SMIN2[w][i][y]<=sa2[i][n][w]<=SMAX2[w][i][y];
 		  			xa0[i][n][w]-za1[i][n][w]+za2[i][n][w]==sa1[i][n][w];
		  			forall(h in HR)UP[i]*(S0[i][y]+xa0[i][n][w])>=xa1[h][i][n][w];
   				}		  	
 				forall(h in HR)sum(i in PR)xa1[h][i][n][w]+15==GS[w][0][y]*Load[h];
				sum(i in PR)UP[i]*(S0[i][y]+xa0[i][n][w])+15>=(1+0.08)*GS[w][0][y]*MaxLoad;
  			}				
		}
		else obj2[n][w]==CC[w]+sum(i in PR)(0.5*AA[w][i]*(S[0][w][i][y][KL[0][w][y][n]]-BB[w][i])*(S[0][w][i][y][KL[0][w][y][n]]-BB[w][i]));
	}			
}  */
/* Convex Hull Approximation (Inner Linearization) in Dual Form 1 */
if(FL[0][1]==1){
	forall(w in WR1,n in 0..NL[0][w][y]-1){
	  	if(y==YS-1)aux2[n][w]==sum(i in PR)S_init[i]*dd1[i][n][w];
	  	else aux2[n][w]==sum(i in PR)S[0][w][i][y][KL[0][w][y][n]]*dd1[i][n][w];
	  	if(y<=YE){
   		  	obj2[n][w]==cost2[n][w]+sum(w2 in WR2)TRP[y+1][w2][w]*vobj2[n][w2][w]+aux2[n][w];
  		  	forall(i in PR)sum(w2 in WR2)TRP[y+1][w2][w]*dd2[i][n][w2][w]==dd0[i][n][w];
			forall(w2 in WR2)if(TRP[y+1][w2][w]>0){
			  	forall(k in 0..LL[0][w2][y+1]-1)vobj2[n][w2][w]<=OBJ2[0][w2][y+1][k]-sum(i in PR)S[0][w2][i][y+1][k]*dd2[i][n][w2][w];
			  	forall(i in PR)-DMAX<=dd2[i][n][w2][w]<=DMAX;
    		}			  	
	  	  	if(y==YS-1){
	  	  	  	cost2[n][w]==0;
	  	  	  	forall(i in PR)-dd0[i][n][w]+dd1[i][n][w]==0;
       		}
       		else{
 	  			cost2[n][w]==sum(h in HR)(GS[w][0][y]*Load[h]-15)*yy1[h][n][w]-sum(i in PR,h in HR)UP[i]*S0[i][y]*yy2[h][i][n][w]
						+((1+0.08)*GS[w][0][y]*MaxLoad-15-sum(i in PR)UP[i]*S0[i][y])*yy3[n][w];
  				forall(i in PR){
		  			if(y==YE)forall(w2 in WR2)AA[w2][i]*(SMIN[w2][i][y+1]-BB[w2][i])<=dd2[i][n][w2][w]<=AA[w2][i]*(SMAX[w2][i][y+1]-BB[w2][i]);
     				-BigM<=yy0[i][n][w]<=BigM;
		   			-dd0[i][n][w]-yy0[i][n][w]+dd1[i][n][w]==0;
   		  			-dd0[i][n][w]<=PFCY[i][y];
		   			UP[i]*(yy3[n][w]+sum(h in HR)yy2[h][i][n][w])+yy0[i][n][w]==0;
 					forall(h in HR)yy1[h][n][w]-yy2[h][i][n][w]<=DISC[y]*PVC[i]*365;
  				}
   			}  			
  		}
  		else obj2[n][w]==CC[w]+sum(i in PR)(0.5*AA[w][i]*(S[0][w][i][y][KL[0][w][y][n]]-BB[w][i])*(S[0][w][i][y][KL[0][w][y][n]]-BB[w][i]));	  
	}
}

/* Convex Hull Approximation (Inner Linearization) in Dual Form 2 */
if(FL[1][0]==1){
	forall(w in WR1,n in 0..NL[1][w][y]-1){
    	forall(i in PR)ctd[i][n][w]:if(y>=YS)d1[i][n][w]==D[1][w][i][y][KL[1][w][y][n]]-y6[i][n][w]+y7[i][n][w];
    	if(y==YS-1)aux3[n][w]==sum(i in PR)S_init[i]*d1[i][n][w];
    	else aux3[n][w]==sum(i in PR)(-SMAX[w][i][y]*y6[i][n][w]+SMIN[w][i][y]*y7[i][n][w]);
	  	if(y<=YE){
			obj3[n][w]==cost3[n][w]+sum(w2 in WR2)TRP[y+1][w2][w]*vobj3[n][w2][w]+aux3[n][w];
  		  	forall(i in PR)sum(w2 in WR2)TRP[y+1][w2][w]*d2[i][n][w2][w]==d0[i][n][w];
		  	forall(w2 in WR2)if(TRP[y+1][w2][w]>0){
				forall(k in 0..LL[1][w2][y+1]-1)vobj3[n][w2][w]<=OBJ1[1][w2][y+1][k]-sum(i in PR)S[1][w2][i][y+1][k]*(d2[i][n][w2][w]-D[1][w2][i][y+1][k]);
		  	  	forall(i in PR)-DMAX<=d2[i][n][w2][w]<=DMAX;
    		}				
			if(y==YS-1){
			  	cost3[n][w]==0;
			  	forall(i in PR)-d0[i][n][w]+d1[i][n][w]==0;
    		}			  	
   			else{		  
 	  			cost3[n][w]==sum(h in HR)(GS[w][0][y]*Load[h]-15)*y1[h][n][w]-sum(i in PR,h in HR)UP[i]*S0[i][y]*y2[h][i][n][w]
					+((1+0.08)*GS[w][0][y]*MaxLoad-15-sum(i in PR)UP[i]*S0[i][y])*y3[n][w];
				forall(i in PR){
		  			if(y==YE)forall(w2 in WR2)AA[w2][i]*(SMIN[w2][i][y+1]-BB[w2][i])<=d2[i][n][w2][w]<=AA[w2][i]*(SMAX[w2][i][y+1]-BB[w2][i]);	
     				-BigM<=y0[i][n][w]<=BigM;
 					-d0[i][n][w]-y0[i][n][w]+d1[i][n][w]==0;
 					-d0[i][n][w]<=PFCY[i][y];
		   			UP[i]*(y3[n][w]+sum(h in HR)y2[h][i][n][w])+y0[i][n][w]==0;
 					forall(h in HR)y1[h][n][w]-y2[h][i][n][w]<=DISC[y]*PVC[i]*365;
  				}
    		}  				
  		}
  		else obj3[n][w]==CC[w]-sum(i in PR)(0.5*AA2[w][i]*D[1][w][i][y][KL[1][w][y][n]]*D[1][w][i][y][KL[1][w][y][n]]+BB[w][i]*D[1][w][i][y][KL[1][w][y][n]]
  		  			+(AA2[w][i]*D[1][w][i][y][KL[1][w][y][n]]+BB[w][i])*(d1[i][n][w]-D[1][w][i][y][KL[1][w][y][n]]))
  		  			+aux3[n][w];		   		
	} 
}

/* Cutting Plane Approximation (Outer Linearization) 2*/ 
if(FL[1][1]==1){
	forall(w in WR1,n in 0..NL[1][w][y]-1){
	  	if(y<=YE){
	  	  	if(y==YS-1)aux4[n][w]==0;
	  	  	else aux4[n][w]==-sum(i in PR)D[1][w][i][y][KL[1][w][y][n]]*ss1[i][n][w];
 	  		obj4[n][w]==cost4[n][w]+sum(w2 in WR2)TRP[y+1][w2][w]*vobj4[n][w2][w]+aux4[n][w];
 	  		forall(w2 in WR2,k in 0..LL[1][w2][y+1]-1)if(TRP[y+1][w2][w]>0)vobj4[n][w2][w]>=OBJ2[1][w2][y+1][k]+sum(i in PR)D[1][w2][i][y+1][k]*ss2[i][n][w];
 	  		if(y==YS-1){
				cost4[n][w]==0;
				forall(i in PR){
				  	ss1[i][n][w]==S_init[i];
				  	ss2[i][n][w]==ss1[i][n][w];
    			}				  
      		}
      		else{ 	  		  
				cost4[n][w]==sum(i in PR)(PFCY[i][y]*xx2[i][n][w]+DISC[y]*PVC[i]*365*sum(h in HR)xx1[h][i][n][w])+BigM*sum(i in PR)(zz1[i][n][w]+zz2[i][n][w]);
				forall(i in PR){
       				SMIN[w][i][y]<=ss1[i][n][w]<=SMAX[w][i][y];
		  			ss2[i][n][w]==xx2[i][n][w]+ss1[i][n][w];
       				SMIN2[w][i][y]<=ss2[i][n][w]<=SMAX2[w][i][y];
		  			xx0[i][n][w]-zz1[i][n][w]+zz2[i][n][w]==ss1[i][n][w];
		  			forall(h in HR)UP[i]*(S0[i][y]+xx0[i][n][w])>=xx1[h][i][n][w];
   				}		  	
 				forall(h in HR)sum(i in PR)xx1[h][i][n][w]+15==GS[w][0][y]*Load[h];
				sum(i in PR)UP[i]*(S0[i][y]+xx0[i][n][w])+15>=(1+0.08)*GS[w][0][y]*MaxLoad;
			}
		}		
		else obj4[n][w]==CC[w]-sum(i in PR)(0.5*AA2[w][i]*D[1][w][i][y][KL[1][w][y][n]]*D[1][w][i][y][KL[1][w][y][n]]
						+BB[w][i]*D[1][w][i][y][KL[1][w][y][n]]);
	}
}	

/* Convex Hull Approximation (Inner Linearization) in Dual Form 3 */
if(FL[2][0]==1){
	forall(w in WR1,n in 0..NL[2][w][y]-1){
	  	forall(i in PR)cte[i][n][w]:if(y>=YS)de0[i][n][w]==D[2][w][i][y][KL[2][w][y][n]]-ye6[i][n][w]+ye7[i][n][w];
		if(y==YS-1)aux5[n][w]==sum(i in PR)S_init[i]*de0[i][n][w];
		else aux5[n][w]==sum(i in PR)(-SMAX[w][i][y]*ye6[i][n][w]+SMIN[w][i][y]*ye7[i][n][w]);	
		if(y<=YE){
	  	  	obj5[n][w]==sum(w2 in WR2)TRP[y+1][w2][w]*(cost5[n][w2][w]+vobj5[n][w2][w])+aux5[n][w];						
			forall(i in PR)sum(w2 in WR2)TRP[y+1][w2][w]*de1[i][n][w2][w]==de0[i][n][w];
   		  	forall(w2 in WR2)if(TRP[y+1][w2][w]>0){
   		  	  	forall(k in 0..LL[2][w2][y+1]-1)vobj5[n][w2][w]<=OBJ1[2][w2][y+1][k]-sum(i in PR)S[2][w2][i][y+1][k]*(de2[i][n][w2][w]-D[2][w2][i][y+1][k]);
   		  	  	forall(i in PR)-DMAX<=de2[i][n][w2][w]<=DMAX;
   		  	  	if(y==YE){
   		  	    	cost5[n][w2][w]==0;
  	  	  			forall(i in PR){
  	  	  			  	AA[w2][i]*(SMIN[w2][i][y+1]-BB[w2][i])<=de2[i][n][w2][w]<=AA[w2][i]*(SMAX[w2][i][y+1]-BB[w2][i]);
						-de2[i][n][w2][w]+de1[i][n][w2][w]==0;
    				}						
   				}
   				else{
       		  		cost5[n][w2][w]==sum(h in HR)(GS[w2][0][y+1]*Load[h]-15)*ye1[h][n][w2][w]-sum(i in PR,h in HR)UP[i]*S0[i][y+1]*ye2[h][i][n][w2][w]
							+((1+0.08)*GS[w2][0][y+1]*MaxLoad-15-sum(i in PR)UP[i]*S0[i][y+1])*ye3[n][w2][w];
					forall(i in PR){			  
		  				-BigM<=ye0[i][n][w2][w]<=BigM;
						-de2[i][n][w2][w]-ye0[i][n][w2][w]+de1[i][n][w2][w]==0;
 						-de2[i][n][w2][w]<=PFCY[i][y+1];
		   				UP[i]*(ye3[n][w2][w]+sum(h in HR)ye2[h][i][n][w2][w])+ye0[i][n][w2][w]==0;
 						forall(h in HR)ye1[h][n][w2][w]-ye2[h][i][n][w2][w]<=DISC[y+1]*PVC[i]*365;
  					}
     			}  					
  			}
   		}  			
  		else obj5[n][w]==CC[w]-sum(i in PR)(0.5*AA2[w][i]*D[2][w][i][y][KL[2][w][y][n]]*D[2][w][i][y][KL[2][w][y][n]]+BB[w][i]*D[2][w][i][y][KL[2][w][y][n]]
  		  			+(AA2[w][i]*D[2][w][i][y][KL[2][w][y][n]]+BB[w][i])*(de0[i][n][w]-D[2][w][i][y][KL[2][w][y][n]]))
  		  			+aux5[n][w];
	}
}

/* Cutting Plane Approximation (Outer Linearization) 3*/ 
if(FL[2][1]==1){
	forall(w in WR1,n in 0..NL[2][w][y]-1){
	  	if(y<=YE){
 	  		obj6[n][w]==sum(w2 in WR2)TRP[y+1][w2][w]*(cost6[n][w2][w]+vobj6[n][w2][w])+aux6[n][w];
     		if(y==YS-1){
     		  	forall(i in PR)sse1[i][n][w]==S_init[i];
     		  	aux6[n][w]==0;
        	}     		  	
 	  		else{
 	  		  	forall(i in PR)SMIN[w][i][y]<=sse1[i][n][w]<=SMAX[w][i][y];
 	  		   	aux6[n][w]==-sum(i in PR)D[2][w][i][y][KL[2][w][y][n]]*sse1[i][n][w];
     		}
 	  		forall(w2 in WR2)if(TRP[y+1][w2][w]>0){
 	  		  	forall(k in 0..LL[2][w2][y+1]-1)vobj6[n][w2][w]>=OBJ2[2][w2][y+1][k]+sum(i in PR)D[2][w2][i][y+1][k]*sse2[i][n][w2][w];
 	  			if(y==YE){
 	  		  		cost6[n][w2][w]==0;
         			forall(i in PR)sse1[i][n][w]==sse2[i][n][w2][w];
      			}
      			else {
      		  		cost6[n][w2][w]==sum(i in PR)(PFCY[i][y+1]*xxe2[i][n][w2][w]+DISC[y+1]*PVC[i]*365*sum(h in HR)xxe1[h][i][n][w2][w])
  									+BigM*sum(i in PR)(zze1[i][n][w2][w]+zze2[i][n][w2][w]);
					forall(i in PR){
					  	SMIN[w2][i][y+1]<=sse2[i][n][w2][w]<=SMAX[w2][i][y+1];
		  				sse2[i][n][w2][w]==xxe2[i][n][w2][w]+sse1[i][n][w];
		  				xxe0[i][n][w2][w]-zze1[i][n][w2][w]+zze2[i][n][w2][w]==sse1[i][n][w];
		  				forall(h in HR)UP[i]*(S0[i][y+1]+xxe0[i][n][w2][w])>=xxe1[h][i][n][w2][w];
   					}		  	
 					forall(h in HR)sum(i in PR)xxe1[h][i][n][w2][w]+15==GS[w2][0][y+1]*Load[h];
					sum(i in PR)UP[i]*(S0[i][y+1]+xxe0[i][n][w2][w])+15>=(1+0.08)*GS[w2][0][y+1]*MaxLoad;	  
 				}
   			}
    	}
    	else obj6[n][w]==CC[w]-sum(i in PR)(0.5*AA2[w][i]*D[2][w][i][y][KL[2][w][y][n]]*D[2][w][i][y][KL[2][w][y][n]]
    					+BB[w][i]*D[2][w][i][y][KL[2][w][y][n]]);
	}
}

/* Cutting Plane Approximation (Outer Linearization) 4*/ 
if(FL[3][0]==1){
	forall(w in WR1,n in 0..NL[3][w][y]-1){
	  	forall(i in PR)if(y>=YS)cta[i][n][w]:se1[i][n][w]==S[3][w][i][y][KL[3][w][y][n]];
	  	if(y<=YE){
 	  		obj7[n][w]==sum(w2 in WR2)TRP[y+1][w2][w]*(cost7[n][w2][w]+vobj7[n][w2][w]);
      		if(y==YS-1)forall(i in PR)se1[i][n][w]==S_init[i];
     		forall(w2 in WR2)if(TRP[y+1][w2][w]>0){
 	  		  	forall(k in 0..LL[3][w2][y+1]-1)vobj7[n][w2][w]>=OBJ1[3][w2][y+1][k]+sum(i in PR)D[3][w2][i][y+1][k]*(se2[i][n][w2][w]-S[3][w2][i][y+1][k]);
 	  			if(y==YE){
 	  		  		cost7[n][w2][w]==0;
         			forall(i in PR)se1[i][n][w]==se2[i][n][w2][w];
      			}
      			else {
      		  		cost7[n][w2][w]==sum(i in PR)(PFCY[i][y+1]*xe2[i][n][w2][w]+DISC[y+1]*PVC[i]*365*sum(h in HR)xe1[h][i][n][w2][w])
  									+BigM*sum(i in PR)(ze1[i][n][w2][w]+ze2[i][n][w2][w]);
					forall(i in PR){
					  	SMIN2[w2][i][y+1]<=se2[i][n][w2][w]<=SMAX2[w2][i][y+1]; 
		  				se2[i][n][w2][w]==xe2[i][n][w2][w]+se1[i][n][w];
		  				xe0[i][n][w2][w]-ze1[i][n][w2][w]+ze2[i][n][w2][w]==se1[i][n][w];
		  				forall(h in HR)UP[i]*(S0[i][y+1]+xe0[i][n][w2][w])>=xe1[h][i][n][w2][w];
   					}		  	
 					forall(h in HR)sum(i in PR)xe1[h][i][n][w2][w]+15==GS[w2][0][y+1]*Load[h];
					sum(i in PR)UP[i]*(S0[i][y+1]+xe0[i][n][w2][w])+15>=(1+0.08)*GS[w2][0][y+1]*MaxLoad;	  
 				}
   			}
    	}
    	else obj7[n][w]==CC[w]+sum(i in PR)(0.5*AA[w][i]*(S[3][w][i][y][KL[3][w][y][n]]-BB[w][i])*(S[3][w][i][y][KL[3][w][y][n]]-BB[w][i])
		  		+AA[w][i]*(S[3][w][i][y][KL[3][w][y][n]]-BB[w][i])*(se1[i][n][w]-S[3][w][i][y][KL[3][w][y][n]]));			 				
	}
}

/* Convex Hull Approximation (Inner Linearization) in Dual Form 4 */
if(FL[3][1]==1){
	forall(w in WR1,n in 0..NL[3][w][y]-1){
		if(y==YS-1)aux8[n][w]==sum(i in PR)S_init[i]*dde0[i][n][w];
		else aux8[n][w]==sum(i in PR)S[3][w][i][y][KL[3][w][y][n]]*dde0[i][n][w];
		if(y<=YE){
	  	  	obj8[n][w]==sum(w2 in WR2)TRP[y+1][w2][w]*(cost8[n][w2][w]+vobj8[n][w2][w])+aux8[n][w];						
			forall(i in PR)sum(w2 in WR2)TRP[y+1][w2][w]*dde1[i][n][w2][w]==dde0[i][n][w];
   		  	forall(w2 in WR2)if(TRP[y+1][w2][w]>0){
   		  	  	forall(k in 0..LL[3][w2][y+1]-1)vobj8[n][w2][w]<=OBJ2[3][w2][y+1][k]-sum(i in PR)S[3][w2][i][y+1][k]*dde2[i][n][w2][w];
   		  	  	forall(i in PR)-DMAX<=dde2[i][n][w2][w]<=DMAX;
   		  	  	if(y==YE){
   		  	    	cost8[n][w2][w]==0;
  	  	  			forall(i in PR){
  	  	  			  	AA[w2][i]*(SMIN[w2][i][y+1]-BB[w2][i])<=dde2[i][n][w2][w]<=AA[w2][i]*(SMAX[w2][i][y+1]-BB[w2][i]);
						-dde2[i][n][w2][w]+dde1[i][n][w2][w]==0;
    				}						
   				}
   				else{
       		  		cost8[n][w2][w]==sum(h in HR)(GS[w2][0][y+1]*Load[h]-15)*yye1[h][n][w2][w]-sum(i in PR,h in HR)UP[i]*S0[i][y+1]*yye2[h][i][n][w2][w]
							+((1+0.08)*GS[w2][0][y+1]*MaxLoad-15-sum(i in PR)UP[i]*S0[i][y+1])*yye3[n][w2][w];
					forall(i in PR){			  
		  				-BigM<=yye0[i][n][w2][w]<=BigM;
						-dde2[i][n][w2][w]-yye0[i][n][w2][w]+dde1[i][n][w2][w]==0;
 						-dde2[i][n][w2][w]<=PFCY[i][y+1];
		   				UP[i]*(yye3[n][w2][w]+sum(h in HR)yye2[h][i][n][w2][w])+yye0[i][n][w2][w]==0;
 						forall(h in HR)yye1[h][n][w2][w]-yye2[h][i][n][w2][w]<=DISC[y+1]*PVC[i]*365;
  					}
     			}  					
  			}
   		}  			
  		else obj8[n][w]==CC[w]+sum(i in PR)(0.5*AA[w][i]*(S[3][w][i][y][KL[3][w][y][n]]-BB[w][i])*(S[3][w][i][y][KL[3][w][y][n]]-BB[w][i]));
	}
} 	 

	/* End */		
} 	

int NK[0..WY[y]*SN-1];
int WK[0..WY[y]*SN-1];
int VV[SNR][WR1];
int IFLAG[SNR][WR1];
int FSTOP;
float zero=1e-16;

execute PostProcess{
	var i,j,k,w,w0,w2,m,m0,n,n0,v,v0,v1,v2,v3,u,NC,nn;
	writeln("-----------------post process------------------------");
 	var now = new Date();
    Opl.srand(now.getTime()%Math.pow(2,31));
    if(y>=YS){
  	  	for(w in WR1){
  	  	  	for(n=0;n<NL[0][w][y];n++){
  	  	  	  	n0=KL[0][w][y][n];
  	  	  	  	for(i in PR){
  	  	  		  if(flag[0][w][y][n0]<=0){//INSERT(DBに存在しない)
  	  	  		  SAMPLE_N[0][w][i][y][n0].D=cts[i][n][w].dual;writeln("non");
  	  	  		  }else{//UPDATE(DBに存在する)
  	  	  		  D[0][w][i][y][n0]=cts[i][n][w].dual;
          		  }  	  	  		  
        		}  		  	
  	  	  		OBJ1[0][w][y][n0]=obj1[n][w];
  	  	  		OBJ2[0][w][y][n0]=obj2[n][w];
     		}
  	  	  	for(n=0;n<NL[1][w][y];n++){
   	  	  		n0=KL[1][w][y][n];
  	  	  		for(i in PR){
  	  	  		  if(flag[1][w][y][n0]<=0){//INSERT(DBに存在しない)
  	  	  		  SAMPLE_N[1][w][i][y][n0].S=ctd[i][n][w].dual;
  	  	  		  }else{//UPDATE(DBに存在する)
  	  	  		  S[1][w][y][i][n0]=ctd[i][n][w].dual;
          		  }  	  	  		  
          		}  	 
	   			OBJ1[1][w][y][n0]=obj3[n][w];
   				OBJ2[1][w][y][n0]=obj4[n][w];
     		}
  	  	  	for(n=0;n<NL[2][w][y];n++){
   	  	  		n0=KL[2][w][y][n];
  	  	  		for(i in PR){
  	  	  		  if(flag[2][w][y][n0]<=0){//INSERT(DBに存在しない)
  	  	  		  SAMPLE_N[2][w][i][y][n0].S=cte[i][n][w].dual;
  	  	  		  }else{//UPDATE(DBに存在する)
  	  	  		  S[2][w][i][y][n0]=cte[i][n][w].dual;  
          		  }  	  	  		  
          		}  	 	  	  	
	   			OBJ1[2][w][y][n0]=obj5[n][w];
   				OBJ2[2][w][y][n0]=obj6[n][w];
     		}
     		for(n=0;n<NL[3][w][y];n++){
     		  	n0=KL[3][w][y][n];
  	  	  		for(i in PR){
  	  	  		  if(flag[3][w][y][n0]<=0){//INSERT(DBに存在しない)
  	  	  		  SAMPLE_N[3][w][i][y][n0].D=cta[i][n][w].dual;
  	  	  		  }else{//UPDATE(DBに存在する)
  	  	  		  D[3][w][i][y][n0]=cta[i][n][w].dual;
                  }  	  	  		  
          		}  	  	
  	  	  		OBJ1[3][w][y][n0]=obj7[n][w];
  	  	  		OBJ2[3][w][y][n0]=obj8[n][w];
     		}
		}	
	}

		
if(y<=YE){
	for(w2 in WR2){
		k=0;v2=zero;n0=-1;NC=0;for(w in WR1)NC+=NL[0][w][y];
		for(w in WR1)for(n=0;n<NL[0][w][y];n++){
			VV[n][w]=0;IFLAG[n][w]=-1;
			if(TRP[y+1][w2][w]>0){
				v1=1.e30;
				for(m=0;m<k;m++){v0=0;for(i in PR){v=s2[i][n][w]-s2[i][NK[m]][WK[m]];v0+=v*v;}if(v0<v1)v1=v0;}
				NK[k]=n;WK[k]=w;k++;
				if(v1>0){
				  	VV[n][w]=1+Opl.rand(NC);
					v1=1.e30;m0=-1;
					for(m=0;m<LL[0][w2][y+1];m++){v0=0;for(i in PR){v=s2[i][n][w]-S[0][w2][i][y+1][m];v0+=v*v;}if(v0<v1){v1=v0;m0=m;}}
					if(v1<=zero)IFLAG[n][w]=m0;
  					if(v2<v1){v2=v1;n0=n;w0=w;}
     			}  						
  			}
   		}
   		if(n0!=-1)VV[n0][w0]=NC+1;
    	j=0;k=LL[0][w2][y+1];
		for(m=0;m<NC;m++){
			v=0;n0=-1;
			for(w in WR1)for(n=0;n<NL[0][w][y];n++)if(VV[n][w]>v){v=VV[n][w];n0=n;w0=w;}
		  	if(n0!=-1){
		  	  	VV[n0][w0]=-1;
		  	  	if(IFLAG[n0][w0]==-1){
		  	  		for(i in PR){
		  	  		if(flag[0][w2][y+1][k]<=0){//INSERT(DBに存在しない)
					  SAMPLE_N[0][w2][i][y+1][k].S=s2[i][n0][w0];
  	  	  		  	}else{//UPDATE(DBに存在する)
		  	  		  S[0][w2][i][y+1][k]=s2[i][n0][w0];
        			}		  		  	  		  
		  	  		  //writeln("k:"+0+",w:"+w2+",s:"+i+",y:"+(y+1)+",l:"+k+",S:"+S[0][w2][i][y+1][k]);	
       				}  			  		
  			  		KL[0][w2][y+1][j]=k++;
       			}
       			else KL[0][w2][y+1][j]=IFLAG[n0][w0]; 			  			  		
  				if(++j==SN)break;
    		}  					  
		}
		NL[0][w2][y+1]=j;
		LL[0][w2][y+1]=k;
	}

	for(w2 in WR2){
		k=0;v2=zero;n0=-1;NC=0;for(w in WR1)NC+=NL[1][w][y];
		for(w in WR1)for(n=0;n<NL[1][w][y];n++){
			VV[n][w]=0;IFLAG[n][w]=-1;
			if(TRP[y+1][w2][w]>0){
				v1=1.e30;
				for(m=0;m<k;m++){v0=0;for(i in PR){v=d2[i][n][w2][w]-d2[i][NK[m]][w2][WK[m]];v0+=v*v;}if(v0<v1)v1=v0;}
				NK[k]=n;WK[k]=w;k++;
				if(v1>0){
				  	VV[n][w]=1+Opl.rand(NC);
					v1=1.e30;m0=-1;
					for(m=0;m<LL[1][w2][y+1];m++){v0=0;for(i in PR){v=d2[i][n][w2][w]-D[1][w2][i][y+1][m];v0+=v*v;}if(v0<v1){v1=v0;m0=m;}}
					if(v1<=zero)IFLAG[n][w]=m0;
  					if(v2<v1){v2=v1;n0=n;w0=w;}
     			}  						
  			}
   		}
   		if(n0!=-1)VV[n0][w0]=NC+1;
   		j=0;k=LL[1][w2][y+1];
		for(m=0;m<NC;m++){
			v=0;n0=-1;
			for(w in WR1)for(n=0;n<NL[1][w][y];n++)if(VV[n][w]>v){v=VV[n][w];n0=n;w0=w;}
		  	if(n0!=-1){
		  	  	VV[n0][w0]=-1;
		  	  	if(IFLAG[n0][w0]==-1){
	  				for(i in PR){
	  				if(flag[1][w2][y+1][k]<=0){//INSERT(DBに存在しない)
					  SAMPLE_N[1][w2][i][y+1][k].D=d2[i][n0][w2][w0];
  	  	  		  	}else{//UPDATE(DBに存在する)
		  	  		  D[1][w2][i][y+1][k]=d2[i][n0][w2][w0];
        			}
     				//writeln("k:"+1+",w:"+w2+",s:"+i+",y:"+(y+1)+",l:"+k+",D:"+D[1][w2][i][y+1][k]);	
     				}	  				
	  				KL[1][w2][y+1][j]=k++;
     			}
     			else KL[1][w2][y+1][j]==IFLAG[n0][w0];	  					  		
  				if(++j==SN)break;
    		}  					  
		}
		NL[1][w2][y+1]=j;
		LL[1][w2][y+1]=k;
	}

	for(w2 in WR2){
		k=0;v2=zero;n0=-1;NC=0;for(w in WR1)NC+=NL[2][w][y];
		for(w in WR1)for(n=0;n<NL[2][w][y];n++){
			VV[n][w]=0;IFLAG[n][w]=-1;
			if(TRP[y+1][w2][w]>0){
				v1=1.e30;
				for(m=0;m<k;m++){v0=0;for(i in PR){v=de2[i][n][w2][w]-de2[i][NK[m]][w2][WK[m]];v0+=v*v;}if(v0<v1)v1=v0;}
				NK[k]=n;WK[k]=w;k++;
				if(v1>0){
				  	VV[n][w]=1+Opl.rand(NC);
					v1=1.e30;m0=-1;
					for(m=0;m<LL[2][w2][y+1];m++){v0=0;for(i in PR){v=de2[i][n][w2][w]-D[2][w2][i][y+1][m];v0+=v*v;}if(v0<v1){v1=v0;m0=m;}}
					if(v1<=zero)IFLAG[n][w]=m0;
  					if(v2<v1){v2=v1;n0=n;w0=w;}
     			}  						
    		}  				
   		}
   		if(n0!=-1)VV[n0][w0]=NC+1;
    	j=0;k=LL[2][w2][y+1];
		for(m=0;m<NC;m++){
			v=0;n0=-1;
			for(w in WR1)for(n=0;n<NL[2][w][y];n++)if(VV[n][w]>v){v=VV[n][w];n0=n;w0=w;}
		  	if(n0!=-1){
		  	  	VV[n0][w0]=-1;
		  	  	if(IFLAG[n0][w0]==-1){
	  				for(i in PR){
	  				if(flag[2][w2][y+1][k]<=0){//INSERT(DBに存在しない)
					  SAMPLE_N[2][w2][i][y+1][k].D=de2[i][n0][w2][w0];
  	  	  		  	}else{//UPDATE(DBに存在する)
	  				  D[2][w2][i][y+1][k]=de2[i][n0][w2][w0];
        			}
	  				  //writeln("k:"+2+",w:"+w2+",s:"+i+",y:"+(y+1)+",l:"+k+",D:"+D[2][w2][i][y+1][k]);	
       				}	  		  		
	  		  		KL[2][w2][y+1][j]=k++;
       			}
       			else KL[2][w2][y+1][j]=IFLAG[n0][w0];	  		
  				if(++j==SN)break;
    		}  					  
		}
		NL[2][w2][y+1]=j;
		LL[2][w2][y+1]=k;
	}

	for(w2 in WR2){
		k=0;v2=zero;n0=-1;NC=0;for(w in WR1)NC+=NL[3][w][y];
		for(w in WR1)for(n=0;n<NL[3][w][y];n++){
			VV[n][w]=0;IFLAG[n][w]=-1;
			if(TRP[y+1][w2][w]>0){
				v1=1.e30;
				for(m=0;m<k;m++){v0=0;for(i in PR){v=se2[i][n][w2][w]-se2[i][NK[m]][w2][WK[m]];v0+=v*v;}if(v0<v1)v1=v0;}
				NK[k]=n;WK[k]=w;k++;
				if(v1>0){
				  	VV[n][w]=1+Opl.rand(NC);
					v1=1.e30;m0=-1;
					for(m=0;m<LL[3][w2][y+1];m++){v0=0;for(i in PR){v=se2[i][n][w2][w]-S[3][w2][i][y+1][m];v0+=v*v;}if(v0<v1){v1=v0;m0=m;}}
					if(v1<=zero)IFLAG[n][w]=m0;
  					if(v2<v1){v2=v1;n0=n;w0=w;}	
 				}
 			}
   		}
   		if(n0!=-1)VV[n0][w0]=NC+1;
    	j=0;k=LL[3][w2][y+1];
		for(m=0;m<NC;m++){
			v=0;n0=-1;
			for(w in WR1)for(n=0;n<NL[3][w][y];n++)if(VV[n][w]>v){v=VV[n][w];n0=n;w0=w;}
		  	if(n0!=-1){
		  	  	VV[n0][w0]=-1;
		  	  	if(IFLAG[n0][w0]==-1){
	  				for(i in PR){
	  				if(flag[3][w2][y+1][k]<=0){//INSERT(DBに存在しない)
					  SAMPLE_N[3][w2][i][y+1][k].S=se2[i][n0][w2][w0];
  	  	  		  	}else{//UPDATE(DBに存在する)
	  				  S[3][w2][i][y+1][k]=se2[i][n0][w2][w0];
        			}
	  				  //writeln("k:"+3+",w:"+w2+",s:"+i+",y:"+(y+1)+",l:"+k+",S:"+S[3][w2][i][y+1][k]);
     				}	  					
	  				KL[3][w2][y+1][j]=k++;
     			}
     			else KL[3][w2][y+1][j]=IFLAG[n0][w0];
  				if(++j==SN)break;
    		}  					  
		}
		NL[3][w2][y+1]=j;
		LL[3][w2][y+1]=k;
	}	
}

if(y>=YS){
    for(w in WR1){
  	   	for(n=0;n<NL[1][w][y];n++){
   	   		n0=KL[1][w][y][n];
  	   		for(i in PR){
		  	  	if(flag[1][w][y][n0]<=0){//INSERT(DBに存在しない)
					v=SAMPLE_N[1][w][i][y][n0].S;;
  	  	  		}else{//UPDATE(DBに存在する)
		  	  		v=S[1][w][i][y][n0];
        		}	
 	  			if(FL[1][0]==1&&v>(u=SMAX[w][i][y])){
 	  				if(v>u+1e-8)writeln("Upper Limit Violation of S[1][",w,"][",i,"][",y,"]:",v," > ",u);
 	  				v=u;
      			} 	  				
		  		if(FL[1][0]==1&&v<(u=SMIN[w][i][y])){
		  			if(v<u-1e-8)writeln("Lower Limit Violation of S[1][",w,"][",i,"][",y,"]:",v," < ",u);
		  			v=u;
      			}
		  	  	if(flag[1][w][y][n0]<=0){//INSERT(DBに存在しない)
					SAMPLE_N[1][w][i][y][n0].S=v;
  	  	  		}else{//UPDATE(DBに存在する)
		  	  		S[1][w][i][y][n0]=v;
        		}	
           	}  	  	  	  	  	
     	}
  	  	for(n=0;n<NL[2][w][y];n++){
   	  		n0=KL[2][w][y][n];
  	  		for(i in PR){
		  	  	if(flag[2][w][y][n0]<=0){//INSERT(DBに存在しない)
					v=SAMPLE_N[2][w][i][y][n0].S;
  	  	  		}else{//UPDATE(DBに存在する)
		  	  		v=S[2][w][i][y][n0];
        		}	
 	  			if(FL[2][0]==1&&v>(u=SMAX[w][i][y])){
 	  				if(v>u+1e-8)writeln("Upper Limit Violation of S[2][",w,"][",i,"][",y,"]:",v," > ",u);
 	  				v=u;
      			} 	  				
		  		if(FL[2][0]==1&&v<(u=SMIN[w][i][y])){
		  			if(v<u-1e-8)writeln("Lower Limit Violation of S[2][",w,"][",i,"][",y,"]:",v," < ",u);
		  			v=u;
      			}
		  	  	if(flag[2][w][y][n0]<=0){//INSERT(DBに存在しない)
					SAMPLE_N[2][w][i][y][n0].S=v;
  	  	  		}else{//UPDATE(DBに存在する)
		  	  		S[2][w][i][y][n0]=v;
        		}	 	  		
           	} 	  	  	  	  	
     	}
	}
}	
if(y<=YE){
  	for(w2 in WR2){
 	  	for(n=0;n<NL[0][w2][y+1];n++){
   	  		n0=KL[0][w2][y+1][n];
  			for(i in PR){
		  	  	if(flag[0][w2][y+1][n0]<=0){//INSERT(DBに存在しない)
					v=SAMPLE_N[0][w2][i][y+1][n0].S;//writeln("SAMPLE_N:"+SAMPLE_N[0][w2][i][y+1][n0]);
  	  	  		}else{//UPDATE(DBに存在する)
		  	  		v=S[0][w2][i][y+1][n0];//writeln("S:"+S[0][w2][i][y+1][n0]+" flag:"+flag[0][w2][y+1][n0]);
        		}	
				if(FL[0][0]==1&&v>(u=SMAX[w][i][y])){
	  				if(v>u+1e-8)writeln("Upper Limit Violation of S[0][",w,"][",i,"][",y,"]:",v," > ",u);
  					v=u;
   				}
   				else if(FL[0][0]==1&&v<(u=SMIN[w][i][y])){
  					if(v<u-1e-8)writeln("Lower Limit Violation of S[0][",w,"][",i,"][",y,"]:",v," < ",u);
					v=u;
    			} 	  	
		  	  	if(flag[0][w2][y+1][n0]<=0){//INSERT(DBに存在しない)
					SAMPLE_N[0][w2][i][y+1][n0].S=v;
  	  	  		}else{//UPDATE(DBに存在する)
			  		S[0][w2][i][y+1][n0]=v;
        		}		  			  	
    		}
    	}    		  					  
   	  	for(n=0;n<NL[3][w2][y+1];n++){
   	  		n0=KL[3][w2][y+1][n];
   	  		for(i in PR){
		  	  	if(flag[3][w2][y+1][n0]<=0){//INSERT(DBに存在しない)
					v=SAMPLE_N[3][w2][i][y+1][n0].S;
  	  	  		}else{//UPDATE(DBに存在する)
		  	  		v=S[3][w2][i][y+1][n0];
        		}	
				if(FL[3][0]==1&&v>(u=SMAX[w][i][y])){
 		  			if(v>u+1e-8)writeln("Upper Limit Violation of S[3][",w,"][",i,"][",y,"]:",v," > ",u);
 	  				v=u;
    			}
    			else if(FL[3][0]==1&&v<(u=SMIN[w][i][y])){
 	  				if(v<u-1e-8)writeln("Lower Limit Violation of S[3][",w,"][",i,"][",y,"]:",v," < ",u);
					v=u;
    			}
		  	  	if(flag[3][w2][y+1][n0]<=0){//INSERT(DBに存在しない)
					SAMPLE_N[3][w2][i][y+1][n0].S=v;
  	  	  		}else{//UPDATE(DBに存在する)
			  		S[3][w2][i][y+1][n0]=v;
        		}
    		}
    	}
	}     	
}

	if(y==YS-1){
   		//writeln(" KL : ",KL);
 		for(i in KR){
   			if(FL[i][0]==1){
   				for(w in WR){
   			  		write(" TYPE",i," LL: ");
   			  		for(y=YE+1;y>=YS;y--)write(LL[i][w][y]," ");
   			  		write(" NL: ");
   			  		for(y=YE+1;y>=YS-1;y--)write(NL[i][w][y]," ");
   			  		writeln();
      			}   			  
      		}
     	}      	
      	   		  
	  	writeln("            Upper Bound           Lower Bound           Gap ");
	  	if(FL[0][0]==1)writeln(" Primal  :  ",J2," ,   ",J1," ,   ",J2-J1);
	  	if(FL[1][0]==1)writeln("   Dual  :  ",J3," ,   ",J4," ,   ",J3-J4);
	  	if(FL[2][0]==1)writeln(" Ex.Dual :  ",J5," ,   ",J6," ,   ",J5-J6);
	  	if(FL[3][0]==1)writeln("Ex.Primal:  ",J8," ,   ",J7," ,   ",J8-J7);
			// 	if(DAT3.J2-DAT3.J1<1.e-4&&DAT3.J2-DAT3.J1>-1.e-4)FSTOP=1;
	  		 if((J2-J1)/J1<1.e-4&&(J2-J1)/J1>-1.e-4)FSTOP=1;
	  	
	  	
  	}	  	
  		//データベースに格納する手法番号
  		if(FL[0][0]==1)k=0;
	  	if(FL[1][0]==1)k=1;
	  	if(FL[2][0]==1)k=2;
	  	if(FL[3][0]==1)k=3;

	  	writeln("writing in DB...");
}

  
  tuple obj {
  float obj1;
  float obj2;
  int flag;
  int flag2;
  int k;//手法
  int w;//シナリオ番号
  int y;//時点番号
  int l;//サンプル点番号
  int update_or_not;//flagをここにいれてやる(DBのflagより大きくない上書きを行わない。)
  }   

 tuple samp {//for update
  float S;
  float D;
  int k;//とき方
  int w;//シナリオ番号
  int y;//時点番号
  int l;//何番目のサンプル点か、番号
  int ss;//状態変数
  }
  
  tuple obj_n {
  int k;//手法
  int w;//シナリオ番号
  int y;//時点番号
  int l;//サンプル点番号
  float obj1;
  float obj2;
  int flag;
  int flag2;
  }   
  
 tuple samp_n {//for insert
  int k;//とき方
  int w;//シナリオ番号
  int y;//時点番号
  int l;//何番目のサンプル点か、番号
  int ss;
  float S;
  float D;
  }

{obj} Obj={<OBJ1[0][w][y][KL[0][w][y][n]],OBJ2[0][w][y][KL[0][w][y][n]],flag[0][w][y][KL[0][w][y][n]],flag2[0][w][y][KL[0][w][y][n]]
			,0,w,y,KL[0][w][y][n],flag[0][w][y][KL[0][w][y][n]]>
			|w in WR, y in YRU, n in 0..(NL[0][w][y]-1):flag[0][w][y][KL[0][w][y][n]]!=0};
		
{samp} Samp={<S[0][w][i][y][KL[0][w][y][n]],D[0][w][i][y][KL[0][w][y][n]],0,w,y,KL[0][w][y][n],i>
			|w in WR, y in YRU, n in 0..(NL[0][w][y]-1), i in PR:flag[0][w][y][KL[0][w][y][n]]!=0};
			
{obj_n} Obj_n={<0,w,y,KL[0][w][y][n],OBJ1[0][w][y][KL[0][w][y][n]],OBJ2[0][w][y][KL[0][w][y][n]],1,maxl(1,(y-YE)+1)>
			|w in WR, y in YRU, n in 0..(NL[0][w][y]-1):(SAMPLE_N[0][w][0][y][KL[0][w][y][n]].S!=0||SAMPLE_N[0][w][0][y][KL[0][w][y][n]].D!=0)&&flag[0][w][y][KL[0][w][y][n]]<=0};//挿入判定i=0のときのみ

{samp_n} Samp_n={<0,w,y,KL[0][w][y][n],i,SAMPLE_N[0][w][i][y][KL[0][w][y][n]].S,SAMPLE_N[0][w][i][y][KL[0][w][y][n]].D>//YE+1時点のみflag2=2
			|w in WR, y in YRU, n in 0..(NL[0][w][y]-1),i in PR:(SAMPLE_N[0][w][i][y][KL[0][w][y][n]].S!=0||SAMPLE_N[0][w][i][y][KL[0][w][y][n]].D!=0)&&flag[0][w][y][KL[0][w][y][n]]<=0};

{int} fstop={FSTOP|h in 0..0:FSTOP!=0};

