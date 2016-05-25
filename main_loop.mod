/*********************************************
 * OPL 12.5 Model
 * Author: uchida
 * Creation Date: 2015/11/18 at 15:24:23
 *********************************************/
 
string GET="1,0,-1";//計算用データを渡します。何も入力しない場合はIteration:1,Thread-operation:0,y:-1でデータが渡されます。(収束確認)
//GET="1,2,0";//J2の値更新用
//GET="0,0,10";//エクセルのパラメータを更新。
//GET="1,1,4";
main{
    //Get external data for calculation
	var g = thisOplModel.GET.split(",");//dataset:[0]Iteration[1]Thread-operation[2]y[3]w
	var Iteration = parseInt(g[0]);//[0]Iteration
	var K = parseInt(g[1]);
	/**[1]Thread-operation
	K=0:J1 and J2 for 
	K=1:only J1
	K=2:only J2
	**/
	var Yn = parseInt(g[2]);//[2]y
	//var Wn;//[3]w
    
//    if(K == 1){
//      Wn = parseInt(g[3]);
//    }
    
    if(Iteration == -1){//Move the input parameters to the SQL Server from excel
    var MAKE_INIT_SRC= new IloOplModelSource("Make_Init_data.mod");
	var MAKE_INIT_DEF= new IloOplModelDefinition(MAKE_INIT_SRC);
	var MAKE_INIT_IN	= new IloOplDataSource("Make_Init_data.dat");
	writeln("Generating input data for calculation...");
	var MAKE_INIT	= new IloOplModel(MAKE_INIT_DEF,cplex);
	MAKE_INIT.addDataSource(MAKE_INIT_IN);									
	MAKE_INIT.generate();
	if(cplex.solve())MAKE_INIT.postProcess();	
	MAKE_INIT.end();
	MAKE_INIT_SRC.end();
	writeln("Fin generating input data.");
    }else{
    
    //収束判定
	var FSTOP_SRC= new IloOplModelSource("FSTOP.mod");
	var FSTOP_DEF= new IloOplModelDefinition(FSTOP_SRC);
	var FSTOP_IN	= new IloOplDataSource("FSTOP.dat");    
	var FSTOP	= new IloOplModel(FSTOP_DEF,cplex);
	FSTOP.addDataSource(FSTOP_IN);									
	FSTOP.generate();
	writeln("FSTOP = ",FSTOP.FSTOP);
	
	if(FSTOP.FSTOP==0){
	//Preparation for Initialization of parameters
	var INIT_SRC= new IloOplModelSource("Init.mod");
	var INIT_DEF= new IloOplModelDefinition(INIT_SRC);
	var INIT_IN	= new IloOplDataSource("Init.dat");
	var DAT		= new IloOplDataElements;
	var DAT2	= new IloOplDataElements;
	var DAT3	= new IloOplDataElements;
	
	writeln("Initialization");
	var INIT	= new IloOplModel(INIT_DEF,cplex);
	INIT.addDataSource(INIT_IN);									
	INIT.generate();
	
	DAT.Y=INIT.Y;
	DAT.YS=INIT.YS;
	DAT.YE=INIT.YE;
	DAT.P=INIT.P;
	DAT.W=INIT.W;
	DAT.H=INIT.H;
	DAT.N=INIT.N;
	DAT.L=INIT.L;
	DAT.Load=INIT.Load;
	DAT.MaxLoad=INIT.MaxLoad;
	DAT.PVC=INIT.PVC;
	DAT.UP=INIT.UP;
	DAT.GS=INIT.GS;
	DAT.DISC=INIT.DISC;
	DAT.PFCY=INIT.PFCY;
	DAT.S0=INIT.S0;
	DAT.TRP=INIT.TRP;
	DAT.WY=INIT.WY;
	DAT.AA=INIT.AA;
	DAT.AA2=INIT.AA2;
	DAT.BB=INIT.BB;
	DAT.CC=INIT.CC;
	
	DAT2.SN=INIT.SN;
	if(Iteration == 0 && Yn == DAT.YE+1){//for Adp_init.mod
		DAT2.S =INIT.S;
		DAT2.D =INIT.D;
		DAT2.OBJ1=INIT.OBJ1;
		DAT2.OBJ2=INIT.OBJ2;
		DAT2.KL=INIT.KL;
	}	
	DAT2.LL=INIT.LL;
	DAT2.NL=INIT.NL;
	DAT2.SMAX=INIT.SMAX;
	DAT2.SMIN=INIT.SMIN;
	DAT2.SMAX2=INIT.SMAX2;
	DAT2.SMIN2=INIT.SMIN2;
	DAT2.S_init=INIT.S_init;
	DAT2.DMAX=INIT.DMAX;
	DAT2.BigM=INIT.BigM;
	DAT2.FL =INIT.FL;
	
	INIT.end();
	INIT_SRC.end();
	writeln("fin init.");

	//Approximated Dynamic Programming
	writeln("start ADP.");
	//var SEL_SRC	= new IloOplModelSource("Select.mod");		
	//var SEL_DEF	= new IloOplModelDefinition(SEL_SRC);
	var ADP_SRC	= new IloOplModelSource("Adp_loop.mod");		
	var ADP_DEF	= new IloOplModelDefinition(ADP_SRC);
	var ADP_LOOP	= new IloOplDataSource("Adp_loop.dat");
	
	var ADP_SRC_J1	= new IloOplModelSource("Adp_loop_J1.mod");		
	var ADP_DEF_J1	= new IloOplModelDefinition(ADP_SRC_J1);
	var ADP_LOOP_J1	= new IloOplDataSource("Adp_loop_J1.dat");
	
	var ADP_SRC_J2	= new IloOplModelSource("Adp_loop_J2.mod");		
	var ADP_DEF_J2	= new IloOplModelDefinition(ADP_SRC_J2);
	var ADP_LOOP_J2	= new IloOplDataSource("Adp_loop_J2.dat");
	
	var ADP_SRC_INIT	= new IloOplModelSource("Adp_init.mod");		
	var ADP_DEF_INIT	= new IloOplModelDefinition(ADP_SRC_INIT);
	var ADP_IN	= new IloOplDataSource("Adp_init.dat");
	
	var id;
	var ADP;
	

	//繰り返し回数
	  	writeln("\nIteration ",Iteration);
		writeln("Stage ",Yn)
			DAT2.y=Yn;
			//DAT2.It=Iteration;
			
			if(Iteration == 0 && Yn == DAT.YE+1){
				ADP = new IloOplModel(ADP_DEF_INIT,cplex);
				ADP.addDataSource(ADP_IN);
			}else{
			  	if(K == 0){			  
				ADP = new IloOplModel(ADP_DEF,cplex);
				ADP.addDataSource(ADP_LOOP);
   				}
   				if(K == 1){
   				writeln("Part J1")
   				ADP = new IloOplModel(ADP_DEF_J1,cplex);
				ADP.addDataSource(ADP_LOOP_J1);
   				}
   				if(K == 2){
   				writeln("Part J2")
   				ADP = new IloOplModel(ADP_DEF_J2,cplex);
				ADP.addDataSource(ADP_LOOP_J2);
   				} 			  		  
 			}			
				ADP.addDataSource(DAT);
				ADP.addDataSource(DAT2);
				ADP.generate();
				
			if(cplex.solve()){
				ADP.postProcess();
			}		
			else{
				id=cplex.getCplexStatus();
	  			if(id==3)write(" Infeasible ",id);
	  			else if(id==4)write(" Infeasible or Unbounded ",id);
	  			else if(id==2)write(" Unbounded ",id);
	  			else write("Failure ",id," ");
			  	stop();
			}
			ADP.end();
			
		if(Iteration == 0 && Yn == DAT.YE+1){
		ADP_SRC_INIT.end();
		}else{
		if(K == 0)ADP_SRC.end();
		if(K == 1)ADP_SRC_J1.end();
		if(K == 2)ADP_SRC_J2.end();
		}	
		writeln("Calculation has been done.");
	}else{
	    writeln("The value meeted preset convergence conditions. All done.");
	}
	}
}
