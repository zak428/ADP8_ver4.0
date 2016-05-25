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
  int flag;//0:無し　1:未計算　2:計算済み　n(n>=2):n-1回計算済み(ここではflag2)
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
  float obj2;
  int flag;
  int flag2;
}

/*サンプル点の値の情報*/
{ADP_sample_point} samp_SD = ...;
float S[KR0][WR][PR][YR0][LR] = [v.k:[v.w:[v.ss:[v.y:[v.l:v.S]]]]|v in samp_SD : (v.y==maxl(YS,y) || v.y==minl(y+1,YE+1)) ];
float D[KR0][WR][PR][YR0][LR] = [v.k:[v.w:[v.ss:[v.y:[v.l:v.D]]]]|v in samp_SD : (v.y==maxl(YS,y) || v.y==minl(y+1,YE+1)) ];
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
//float OBJ1[KR0][WR][YR0][LR] = [v.k:[v.w:[v.y:[v.l:v.obj1]]]|v in obj_db : (v.y==maxl(YS,y) || v.y==minl(y+1,YE+1)) ];
float OBJ2[KR0][WR][YR0][LR] = [v.k:[v.w:[v.y:[v.l:v.obj2]]]|v in obj_db : (v.y==maxl(YS,y) || v.y==minl(y+1,YE+1)) ];
int flag[KR0][WR][YR0][LR] = [v.k:[v.w:[v.y:[v.l:v.flag]]]|v in obj_db : (v.y==maxl(YS,y) || v.y==minl(y+1,YE+1)) ];
int flag2[KR0][WR][YR0][LR] = [v.k:[v.w:[v.y:[v.l:v.flag2]]]|v in obj_db : (v.y==maxl(YS,y) || v.y==minl(y+1,YE+1)) ];

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
    				if(y==yy){flag2[k][w][yy][KL[k][w][yy][t]]++;}//計算済み判定 
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
    	   	for(i in PR){//初期化
		 		//S[k][w][i][yy][l]=(SMIN[w][i][y]+SMAX[w][i][y])/2;
				//D[k][w][i][yy][l]=0;
			}
    	}    
    		 
    	if(flag2[k][w][yy][l]>=1){
    	}else{
    	   flag2[k][w][yy][l]=0;
    	   OBJ2[k][w][yy][l]=0;
    	}
    	
    	if(yy == y+1 && y<=(YE-1) && k == 0){//FL[0][1]==1       	  
    		if((OBJ2[k][w][y+1][l] == 0/* || OBJ_DB[k][w][y+1][l].obj2+0.001<OBJ_DB[k][w][y+1][l].obj1*/)){
    		  OBJ2[k][w][y+1][l]=0;
    		  penalty=0;
    		  
    		  //penalty for FL[0][1]==1 廃止
//    		  for(w2 in WR){penalty += TRP[y+1][w2][w]*DMAX;}
//    		    if(y==YS-1){
//    		    for(i in PR){OBJ2[k][w][y+1][l]+=S_init[i]*(penalty);}
//      			}else{    		  
//    		    for(i in PR){OBJ2[k][w][y+1][l]+=S[k][w][i][y+1][l]*(penalty + BigM);}
//           		}           		
//           		writeln("y:"+yy+" l:"+l+" w:"+w+" obj2:"+OBJ2[k][w][y+1][l]+" calibration.");  
    		  if(OBJ2[k][w][y+1][l] == 0){//データベースの読み込みの際のずれのキャリブレーション(点が存在しているのにSが0で読み込まれる場合)
    		    //for(i in PR){OBJ2[k][w][y+1][l]+=S_init[i]*(penalty+BigM);}
    		    writeln("y:"+yy+" l:"+l+" w:"+w+" S:"+S[k][w][0][y+1][l]+" S:"+S[k][w][1][y+1][l]+" S:"+S[k][w][2][y+1][l]+" S:"+S[k][w][3][y+1][l]+" obj2:"+OBJ2[k][w][y+1][l]+" stop calibration.");
	   		    LL[k][w][yy]=l;break;//読み込みのずれがなければLL2をLLに代入しそのまま  
     		  }
    		}
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

minimize  -J2-J3+J4-J5+J6+J7-J8;

subject to{
  

  	J2==FL[0][1]*sum(w in WR1,n in 0..NL[0][w][y]-1)obj2[n][w]; //Upper Bound Value
  	J3==FL[1][0]*sum(w in WR1,n in 0..NL[1][w][y]-1)obj3[n][w];	//Upper Bound Value
  	J4==FL[1][1]*sum(w in WR1,n in 0..NL[1][w][y]-1)obj4[n][w];	//Lower Bound Value
 	J5==FL[2][0]*sum(w in WR1,n in 0..NL[2][w][y]-1)obj5[n][w];	//Upper Bound Value
 	J6==FL[2][1]*sum(w in WR1,n in 0..NL[2][w][y]-1)obj6[n][w];	//Lower Bound Value
 	J7==FL[3][0]*sum(w in WR1,n in 0..NL[3][w][y]-1)obj7[n][w];	//Lower Bound Value
 	J8==FL[3][1]*sum(w in WR1,n in 0..NL[3][w][y]-1)obj8[n][w];	//Upper Bound Value
 		  

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
  	  	  		OBJ2[0][w][y][n0]=obj2[n][w];
     		}
  	  	  	for(n=0;n<NL[1][w][y];n++){
   	  	  		n0=KL[1][w][y][n];
   				OBJ2[1][w][y][n0]=obj4[n][w];
     		}
  	  	  	for(n=0;n<NL[2][w][y];n++){
   	  	  		n0=KL[2][w][y][n];
   				OBJ2[2][w][y][n0]=obj6[n][w];
     		}
     		for(n=0;n<NL[3][w][y];n++){
     		  	n0=KL[3][w][y][n];
  	  	  		OBJ2[3][w][y][n0]=obj8[n][w];
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
	  		 if((J2-J1)/J1<1.e-5&&(J2-J1)/J1>-1.e-5)FSTOP=1;
	  	
	  	
  	}	  	
  		//データベースに格納する手法番号
  		if(FL[0][0]==1)k=0;
	  	if(FL[1][0]==1)k=1;
	  	if(FL[2][0]==1)k=2;
	  	if(FL[3][0]==1)k=3;

	  	writeln("writing in DB...");
}

  
  tuple obj {
  float obj2;
  int flag2;
  int k;//手法
  int w;//シナリオ番号
  int y;//時点番号
  int l;//サンプル点番号
  int update_or_not;//flagをここにいれてやる(DBのflagより大きくない上書きを行わない。)
  }   


{obj} Obj={<OBJ2[0][w][y][KL[0][w][y][n]],flag2[0][w][y][KL[0][w][y][n]]
			,0,w,y,KL[0][w][y][n],flag2[0][w][y][KL[0][w][y][n]]>
			|w in WR, y in maxl(YS,y)..maxl(YS,y), n in 0..(NL[0][w][y]-1):flag[0][w][y][KL[0][w][y][n]]!=0&&flag2[0][w][y][KL[0][w][y][n]]>KL_flag[0][w][y][n]};
		
{int} fstop={FSTOP|h in 0..0:FSTOP!=0};

