package control_cplex;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.lang.management.ManagementFactory;
import java.lang.management.ThreadMXBean;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher;
import java.util.regex.Pattern;



public class main {

	static int[] Rt_It = new int[10+2];//現在進行形の反復回数
	static int Rt_It_y1 = 0;//y=-1待機
	static int fin=0;
	static int eternal=6000;//
	/*****************************************設定***********************************************/
	static int SELECT=5;
	//******************************//
	//1:直列計算
	//2:擬似直列計算(ADP8_ver3.0 12thread)
	//4:並列計算(ADP8_ver3.0 12thread)
	//5:並列計算(ADP8_並列 12thread　10時点専用)←卒論で使用したもの
	//6:並列計算(ADP8_並列 12thread　時点数変更用)←要コメントアウトを調整
	//******************************//
	static int Serial_to_Parallel=1;//何週目で並列計算で切り替えるか
	static int wait=100;//J1始まってからまつ時間(秒)
	static int J2_interval=15;//J2のインターバル
	static int loop=5511;//並列計算でループ実行を何回行うか//11*n+11 561
	static int Y=9;//時点数(EXCELで指定したものより1つ小さい値をいれてください)
	static int W=4;//分岐
	static int ver=4;//ver3.0かver4.0か
	//static int interval=60;//インターバルを要すもの(秒)
	/*******************************************************************************************/
	static long[][] CpuTime2 = new long[Y+3][2];//J1 pararell
	static long CpuTime3;//excel
	static long[] CpuTime4 = new long[2];//serial
	static long checkCpuTime;//java
	static long startCpuTime;
	static long start;

		public static void main(String[] args) throws IOException, InterruptedException, ExecutionException {
			// TODO Auto-generated method stub

			//caluculate_minusone_y cp = new caluculate_minusone_y();//task2で使ってた没

			/**実行するコマンド**/
			//test
			String help = "cmd /c oplrun";
			String c999 = "cmd /c oplrun -D GET=1 -c C:\\Users\\uchida\\opl\\OPGM\\OPGM.mod C:\\Users\\uchida\\opl\\OPGM\\OPGM.dat";
			c999 = "cmd /c oplrun -D GET2=2 C:\\Users\\uchida\\opl\\OPGM\\MAIN.mod";
			String forcopy="oplrun -D GET=0,0,-1 C:\\Users\\uchida\\opl\\ADP8_ver3.0\\main_loop.mod";

			//無印用
			String c0 = "cmd /c oplrun C:\\Users\\uchida\\opl\\ADP8\\main.mod";

			//ver2用
			String c1 = "cmd /c oplrun C:\\Users\\uchida\\opl\\ADP8_ver2.0\\main.mod";
			String c2="cmd /c oplrun C:\\Users\\uchida\\opl\\ADP8_ver2.0\\main_loop_y=",c3=".mod";
			int c=9;//時点数

			//ver3,4用
			String c1_ = "cmd /c oplrun C:\\Users\\uchida\\opl\\ADP8_ver"+ver+".0\\main.mod";
			String c_pre = "powershell -Command Measure-Command{oplrun -D GET='";
			String c_pro ="' C:\\Users\\uchida\\opl\\ADP8_ver"+ver+".0\\main_loop.mod | Out-Default}";
			int Iteration=0;
			int YS=0,YE=Y;
			int y=YE+1;
			int w=W-1;
			int stopper=-1;//一週目のみ-1時点を実行します。

			//計測初期化
			CpuTime4[1]=0;
			for(int i=0;i<Y+3;i++){
			CpuTime2[i][1]=0;
			}


			//flexible
			int[] Rt_It = new int[y+2];//現在進行形の反復回数
			int[] k = new int[y+2];//4分岐を4分割計算を行う判定　0:しない　1:する
			for(int i=0;i<Y+3;i++){
				Rt_It[i] = 0; k[i]=0;
			}


			start = System.nanoTime();//時間計測スタート
			ThreadMXBean threadMXBean = ManagementFactory.getThreadMXBean();
			startCpuTime = threadMXBean.getCurrentThreadCpuTime();//java


		    ExecutorService service = Executors.newFixedThreadPool(1);
		    ExecutorService service2 = Executors.newFixedThreadPool(1);
		    Future<String> future0;
		    Future<String> future1;
		    Future<String> future2;
		    Future<String> future3;
		    Future<String> future4;
		    Future<String> future5;
		    Future<String> future6;
		    Future<String> future7;
		    Future<String> future8;
		    Future<String> future9;
		    Future<String> future10;
		    Future<String> future11;
		    Future<String> future12;
		    Future<String> future13;
		    Future<String> future14;
		    Future<String> future15;
		    Future<String> future16;
		    Future<String> future17;
		    Future<String> future18;
		    Future<String> future19;
		    Future<String> future20;
		    Future<String> future21;

		    /*各時点、分岐用のスレッド*/
		    ExecutorService[][] s = new ExecutorService[Y+3][W];//時点のほうは一つずつ上にずらす
		    for(int i=0;i<Y+3;i++){
		    	for(int j=0;j<W;j++){
		    		s[i][j] = Executors.newFixedThreadPool(1);
		    	}
		    }



		    System.out.println("task start");

		    //sql to excel
		    int[] init_params={-1,0,Y+1};
		    Future<String> init = service.submit(new Task(c_pre+mk_par(init_params)+c_pro,0,init_params));
    		System.out.println(init.get()); //ここでメインスレッドがブロックする

		    if(SELECT==1){//ADP8/***************************************************************************************/
		    		int[] params={-1,0,0};
		    		Future<String> future = service.submit(new Task(c0,0,params)); // このタスクの結果を得る
		    		System.out.println(future.get()); // ここでメインスレッドがブロックする
		    		service.shutdown();
	    		    try {
	    		        if (!service.awaitTermination(360000, TimeUnit.SECONDS)) {
	    		        	service.shutdownNow();
	    		            if (!service.awaitTermination(360000, TimeUnit.SECONDS)) {
	    		                System.out.println("ExecutorService did not terminate");
	    		            }
	    		        }
	    		    } catch (InterruptedException e) {
	    		    	service.shutdownNow();
	    		        Thread.currentThread().interrupt();
	    		    }
		    }else if(SELECT==2){//ADP8_ver3.0 1thread(疑似直列)/***************************************************************************************/
		    	Iteration=0;
		    	int[] first_params={Iteration,0,y};
		    	Future<String> future = service.submit(new Task(c_pre+mk_par(first_params)+c_pro,0,first_params));//10時点目
	    		System.out.println(future.get()); //ここでメインスレッドがブロックする
	    		y--;
		    			for(int t=1;t<loop;t++){
		    				Iteration=(int) Math.floor((t)/(Y+1));//切り捨て

		    				int[] params={Iteration,0,y};
		    				future = service.submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    	    		System.out.println(future.get()); //ここでメインスレッドがブロックする

		    				if(y==stopper){y=10;stopper=-1;}else{y--;}
		    			}
		    		    service.shutdown();
		    		    try {
		    		        if (!service.awaitTermination(36000, TimeUnit.SECONDS)) {
		    		        	service.shutdownNow();
		    		            if (!service.awaitTermination(36000, TimeUnit.SECONDS)) {
		    		                System.out.println("ExecutorService did not terminate");
		    		            }
		    		        }
		    		    } catch (InterruptedException e) {
		    		    	service.shutdownNow();
		    		        Thread.currentThread().interrupt();
		    		    }
		    }else if(SELECT==4){//ADP8_ver3.0 12thread nonstop (iteration0=直列)/***************************************************************************************/
		    	int[] first_params={Iteration,0,y};
		    	Future<String> future = s[11][0].submit(new Task(c_pre+mk_par(first_params)+c_pro,0,first_params));//10時点目
	    		System.out.println(future.get()); //ここでメインスレッドがブロックする
	    		y--;
    					for(int t=1;t<11*Serial_to_Parallel+1;t++){
    						Iteration=(int) Math.floor((t)/(Y+1));//切り捨て

    						int[] params={Iteration,0,y};
    						future = s[y+1][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
    	    				System.out.println(future.get()); //ここでメインスレッドがブロックする

    						if(y==stopper){y=10;stopper=0;}else{y--;}
    					}

    						for(int t=11*Serial_to_Parallel+1;t<loop;t++){//J1
		    					Iteration=(int) Math.floor((t)/(Y+2));//切り捨て
		    					int[] params={Iteration,1,y};
		    					s[y+1][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					if(y==0){y=10;}else{y--;}
		    				}

    						Thread.sleep(1000*60*2);//2分待ちます

    						for(int t=11*Serial_to_Parallel+1;t<eternal*(Y+1);t++){//J2
		    					Iteration=(int) Math.floor((t)/(Y+2));//切り捨て
		    					int[] params={Iteration,2,y};
		    					if(y!=0)s[y+1][1].submit(new Task_interval(c_pre+mk_par(params)+c_pro,t,params,3));//この終了は計測時間に含まない。
		    					//if(y==0)service2.submit(new Task_interval(c_pre+mk_par(params)+c_pro,t,params,3));//この終了は計測時間に含まない。
		    					if(y==0){y=10;}else{y--;}//J2のy=0は定期的に回します。
		    				}

//    						for(int t=1;t<eternal;t++){//J2 k=2 y=0をいっぱいまわす
//		    					Iteration=(int) Math.floor((t));//切り捨て
//		    					int[] params={Iteration,2,0};
//		    					service2.submit(new Task_interval(c_pre+mk_par(params)+c_pro,t,params));//この終了は計測時間に含まない。
//		    				}

    						for(int t=1;t<eternal;t++){//k=0 y=-1をいっぱいまわす
		    					Iteration=(int) Math.floor((t));//切り捨て
		    					int[] params={Iteration,2,0};
		    					service.submit(new Task_interval(c_pre+mk_par(params)+c_pro,t,params,0));
		    					params[1]=0;params[2]=-1;
		    					service.submit(new Task_interval(c_pre+mk_par(params)+c_pro,t,params,10));//この終了は計測時間に含まない。
		    				}

		    		    for(int i=0;i<Y+3;i++){
		    		    	for(int j=0;j<1;j++){//j=0のみ待つ。
		    		    		s[i][j].shutdown();
				    		    try {
				    		        if (!s[i][j].awaitTermination(36000, TimeUnit.SECONDS)) {s[i][j].shutdownNow();
				    		            if (!s[i][j].awaitTermination(36000, TimeUnit.SECONDS)) {System.out.println("ExecutorService did not terminate");}
				    		        }
				    		    } catch (InterruptedException e) {s[i][j].shutdownNow();
				    		        Thread.currentThread().interrupt();
				    		    }
		    		    	}
		    		    }
		    }else if(SELECT==5){//4から改良→12個並べてとく
		    	int[] first_params={Iteration,0,y};long mid,m2,m1;int st_J2=0;long maxcpu2;
		    	Future<String> future = s[11][0].submit(new Task(c_pre+mk_par(first_params)+c_pro,0,first_params));//10時点目
	    		System.out.println(future.get()); //ここでメインスレッドがブロックする
	    		y--;
    					for(int t=1;t<(Y+2)*Serial_to_Parallel+1;t++){
    						Iteration=(int) Math.floor((t-1)/(Y+2));//切り捨て

    						int[] params={Iteration,0,y};
    						future = service.submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
    	    				System.out.println(future.get()); //ここでメインスレッドがブロックする

    						if(y==stopper){y=YE+1;stopper=0;}else{y--;}
    					}m1 = System.nanoTime();

    						for(int t=(YE+2)*Serial_to_Parallel+1;t<loop;t++){//J1
		    					Iteration=(int) Math.floor((t)/(Y+2));//切り捨て
		    					int[] params={Iteration,1,YE+1};
		    					future11=s[11][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]=9;
		    					future10=s[10][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]=8;
		    					future9=s[9][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]=7;
		    					future8=s[8][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]=6;
		    					future7=s[7][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]=5;
		    					future6=s[6][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]=4;
		    					future5=s[5][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]=3;
		    					future4=s[4][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]=2;
		    					future3=s[3][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]=1;
		    					future2=s[2][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]=0;
		    					future1=s[1][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));

		    					mid = System.nanoTime();
		    					if((((mid - m1) / 1000000f)/1000) > wait && st_J2==0){//二分経過後　J2起動

		    						for(int h=(YE+2)*Serial_to_Parallel+1;h<eternal*(Y+1);h++){//J2
				    					Iteration=(int) Math.floor((h)/(Y+2));//切り捨て
				    					int[] params2={Iteration,2,y};
				    					if(y!=0)s[y+1][1].submit(new Task_interval(c_pre+mk_par(params2)+c_pro,h,params2,J2_interval));//この終了は計測時間に含まない。
				    					//if(y==0)service2.submit(new Task_interval(c_pre+mk_par(params2)+c_pro,t,params2,3));//この終了は計測時間に含まない。
				    					if(y==0){y=10;}else{y--;}//J2のy=0は定期的に回します。
				    				}

		    						for(int h=1;h<eternal*2;h++){//k=0 y=-1をいっぱいまわす
				    					Iteration=(int) Math.floor((t));//切り捨て
				    					int[] params2={Iteration,2,0};
				    					service.submit(new Task_interval(c_pre+mk_par(params2)+c_pro,t,params2,5));
				    					params2[1]=0;params2[2]=-1;
				    					service.submit(new Task_interval(c_pre+mk_par(params2)+c_pro,t,params2,10));//この終了は計測時間に含まない。
				    				}

		    						st_J2++;
		    					}
		    					checkCpuTime=threadMXBean.getCurrentThreadCpuTime();
		    					future11.get();future10.get();future9.get();future8.get();future7.get();
		    					future6.get();future5.get();future4.get();future3.get();future2.get();future1.get();
		    					maxcpu2=calc_k(CpuTime2);
		    					for(int i=0;i<Y+3;i++)CpuTime2[i][1]=maxcpu2;
		    					t+=11;
		    					m2 = System.nanoTime();
		    					System.out.println("NowTime:" + (m2 - start) / 1000000f + " ms ≒ about "+(((m2 - start) / 1000000f)/60000)+" minutes");
		    					System.out.println("NowCPUTime:" + ((threadMXBean.getCurrentThreadCpuTime()  - startCpuTime)+calc_k(CpuTime2)+CpuTime4[1]+CpuTime3) / 1000000f + "ms≒ about "+((((threadMXBean.getCurrentThreadCpuTime()  - startCpuTime)+calc_k(CpuTime2)+CpuTime4[1]+CpuTime3)/ 1000000f)/60000)+" minutes");
		    				}
		    		    for(int i=0;i<Y+3;i++){
		    		    	for(int j=0;j<1;j++){//j=0のみ待つ。
		    		    		s[i][j].shutdown();
				    		    try {
				    		        if (!s[i][j].awaitTermination(36000, TimeUnit.SECONDS)) {s[i][j].shutdownNow();
				    		            if (!s[i][j].awaitTermination(36000, TimeUnit.SECONDS)) {System.out.println("ExecutorService did not terminate");}
				    		        }
				    		    } catch (InterruptedException e) {s[i][j].shutdownNow();
				    		        Thread.currentThread().interrupt();
				    		    }
		    		    	}
		    		    }

		    }else if(SELECT==8){//4から改良→12個並べてとく select5のY=20
		    	int[] first_params={Iteration,0,y};long mid,m2;int st_J2=0;long maxcpu2;
		    	Future<String> future = s[11][0].submit(new Task(c_pre+mk_par(first_params)+c_pro,0,first_params));//10時点目
	    		System.out.println(future.get()); //ここでメインスレッドがブロックする
	    		y--;
    					for(int t=1;t<Y+2*Serial_to_Parallel+1;t++){
    						Iteration=(int) Math.floor((t)/(Y+2));//切り捨て

    						int[] params={Iteration,0,y};
    						future = s[y+1][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
    	    				System.out.println(future.get()); //ここでメインスレッドがブロックする

    						if(y==stopper){y=YE+1;stopper=0;}else{y--;}
    					}

    						for(int t=YE+2*Serial_to_Parallel+1;t<loop;t++){//J1
		    					Iteration=(int) Math.floor((t)/(Y+2));//切り捨て
		    					int[] params={Iteration,1,YE+1};
//		    					future21=s[21][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
//		    					params[2]--;
//		    					future20=s[20][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
//		    					params[2]--;
//		    					future19=s[19][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
//		    					params[2]--;
//		    					future18=s[18][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
//		    					params[2]--;
//		    					future17=s[17][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
//		    					params[2]--;
//		    					future16=s[16][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
//		    					params[2]--;
//		    					future15=s[15][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
//		    					params[2]--;
//		    					future14=s[14][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
//		    					params[2]--;
//		    					future13=s[13][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
//		    					params[2]--;
		    					future12=s[12][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]--;
		    					future11=s[11][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]--;
		    					future10=s[10][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]--;
		    					future9=s[9][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]--;
		    					future8=s[8][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]--;
		    					future7=s[7][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]--;
		    					future6=s[6][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]--;
		    					future5=s[5][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]--;
		    					future4=s[4][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]--;
		    					future3=s[3][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]--;
		    					future2=s[2][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					params[2]--;
		    					future1=s[1][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));

		    					mid = System.nanoTime();
		    					if((((mid - start) / 1000000f)/1000) > 120 || st_J2==0){//二分経過後　J2起動

		    						for(int h=YE+2*Serial_to_Parallel+1;h<eternal*(Y+1);h++){//J2
				    					Iteration=(int) Math.floor((h)/(Y+2));//切り捨て
				    					int[] params2={Iteration,2,y};
				    					if(y!=0)s[y+1][1].submit(new Task_interval(c_pre+mk_par(params2)+c_pro,h,params2,5));//この終了は計測時間に含まない。
				    					//if(y==0)service2.submit(new Task_interval(c_pre+mk_par(params2)+c_pro,t,params2,3));//この終了は計測時間に含まない。
				    					if(y==0){y=YE+1;}else{y--;}//J2のy=0は定期的に回します。
				    				}

		    						for(int h=1;h<eternal*2;h++){//k=0 y=-1をいっぱいまわす
				    					Iteration=(int) Math.floor((t));//切り捨て
				    					int[] params2={Iteration,2,0};
				    					service.submit(new Task_interval(c_pre+mk_par(params2)+c_pro,t,params2,5));
				    					params2[1]=0;params2[2]=-1;
				    					service.submit(new Task_interval(c_pre+mk_par(params2)+c_pro,t,params2,10));//この終了は計測時間に含まない。
				    				}

		    						st_J2++;
		    					}
		    					//future21.get();future20.get();future19.get();future18.get();future17.get();
		    					//future16.get();future15.get();future14.get();future13.get();
		    					future12.get();
		    					future11.get();future10.get();future9.get();future8.get();future7.get();
		    					future6.get();future5.get();future4.get();future3.get();future2.get();future1.get();
		    					t+=YE+2;
		    					m2 = System.nanoTime();
		    					maxcpu2=calc_k(CpuTime2);
		    					for(int i=0;i<Y+3;i++)CpuTime2[i][1]=maxcpu2;
		    					System.out.println("NowTime:" + (m2 - start) / 1000000f + " ms ≒ about "+(((m2 - start) / 1000000f)/60000)+" minutes");
		    					System.out.println("NowCPUTime:" + ((threadMXBean.getCurrentThreadCpuTime()  - startCpuTime)+calc_k(CpuTime2)+CpuTime4[1]+CpuTime3) / 1000000f + "ms≒ about "+((((threadMXBean.getCurrentThreadCpuTime()  - startCpuTime)+calc_k(CpuTime2)+CpuTime4[1]+CpuTime3)/ 1000000f)/60000)+" minutes");
		    				}


		    		    for(int i=0;i<Y+3;i++){
		    		    	for(int j=0;j<1;j++){//j=0のみ待つ。
		    		    		s[i][j].shutdown();
				    		    try {
				    		        if (!s[i][j].awaitTermination(36000, TimeUnit.SECONDS)) {s[i][j].shutdownNow();
				    		            if (!s[i][j].awaitTermination(36000, TimeUnit.SECONDS)) {System.out.println("ExecutorService did not terminate");}
				    		        }
				    		    } catch (InterruptedException e) {s[i][j].shutdownNow();
				    		        Thread.currentThread().interrupt();
				    		    }
		    		    	}
		    		    }
		    }else if(SELECT==9){//ADP8_ver3.0 12thread nonstop J1/***************************************************************************************/
		    	int[] first_params={Iteration,0,y};
		    	Future<String> future = s[11][0].submit(new Task(c_pre+mk_par(first_params)+c_pro,0,first_params));//10時点目
	    		System.out.println(future.get()); //ここでメインスレッドがブロックする
	    		y--;
    					for(int t=1;t<11*Serial_to_Parallel+1;t++){
    						Iteration=(int) Math.floor((t)/(Y+2));//切り捨て

    						int[] params={Iteration,0,y};
    						future = s[y+1][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
    	    				System.out.println(future.get()); //ここでメインスレッドがブロックする

    						if(y==stopper){y=10;stopper=0;}else{y--;}
    					}

    						for(int t=11*Serial_to_Parallel+1;t<loop;t++){
		    					Iteration=(int) Math.floor((t)/(Y+2));//切り捨て
		    					int[] params={Iteration,1,y};
		    					s[y+1][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
		    					if(y==0){y=10;}else{y--;}
		    				}

//    						for(int t=11*Serial_to_Parallel+1;t<loop;t++){
//		    					Iteration=(int) Math.floor((t)/(Y+1));//切り捨て
//		    					int[] params={Iteration,2,y};
//		    					Future<String> future2 = s[y+1][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
//			    	    		System.out.println(future2.get()); //ここでメインスレッドがブロックする
//		    					if(y==0){y=10;}else{y--;}
//		    				}


		    		    for(int i=0;i<Y+2;i++){
		    		    	for(int j=0;j<W;j++){
		    		    		s[i][j].shutdown();
				    		    try {
				    		        if (!s[i][j].awaitTermination(36000, TimeUnit.SECONDS)) {s[i][j].shutdownNow();
				    		            if (!s[i][j].awaitTermination(36000, TimeUnit.SECONDS)) {System.out.println("ExecutorService did not terminate");}
				    		        }
				    		    } catch (InterruptedException e) {s[i][j].shutdownNow();
				    		        Thread.currentThread().interrupt();
				    		    }
		    		    	}
		    		    }
		    }else if(SELECT==10){//ADP8_ver3.0 12thread nonstop J2(疑似直列)/***************************************************************************************/
		    	Iteration =1;
		    	int[] first_params={Iteration,2,y};
		    	Future<String> future = s[11][0].submit(new Task(c_pre+mk_par(first_params)+c_pro,0,first_params));//10時点目
	    		System.out.println(future.get()); //ここでメインスレッドがブロックする
	    		y--;
    					for(int t=1;t<loop;t++){
    						Iteration=(int) Math.floor((t)/(Y+2));//切り捨て

    						int[] params={Iteration,2,y};
    						/*future = */s[y+1][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
    	    				//System.out.println(future.get()); //ここでメインスレッドがブロックする

    						if(y==stopper){y=10;stopper=0;}else{y--;}
    					}
//    						for(int t=11*Serial_to_Parallel+1;t<loop;t++){
//		    					Iteration=(int) Math.floor((t)/(Y+1));//切り捨て
//		    					int[] params={Iteration,2,y};
//		    					Future<String> future2 = s[y+1][0].submit(new Task(c_pre+mk_par(params)+c_pro,t,params));
//			    	    		System.out.println(future2.get()); //ここでメインスレッドがブロックする
//		    					if(y==0){y=10;}else{y--;}
//		    				}


		    		    for(int i=0;i<Y+2;i++){
		    		    	for(int j=0;j<W;j++){
		    		    		s[i][j].shutdown();
				    		    try {
				    		        if (!s[i][j].awaitTermination(36000, TimeUnit.SECONDS)) {s[i][j].shutdownNow();
				    		            if (!s[i][j].awaitTermination(36000, TimeUnit.SECONDS)) {System.out.println("ExecutorService did not terminate");}
				    		        }
				    		    } catch (InterruptedException e) {s[i][j].shutdownNow();
				    		        Thread.currentThread().interrupt();
				    		    }
		    		    	}
		    		    }
		    }

		    System.out.println("All task end");
			long end = System.nanoTime();//時間計測終了
			long stopCpuTime = threadMXBean.getCurrentThreadCpuTime();
			float second = (((end - start) / 1000000f)/1000);
			float minute = second/60;
			System.out.println("RealTime:" + (end - start) / 1000000f + " ms ≒ about "+minute+" minutes");
			System.out.println("pararell_CPUTime:" + calc_k(CpuTime2) / 1000000f + "ms");
			System.out.println("serial_CPUTime:" + CpuTime4[1] / 1000000f + "ms");
			System.out.println("excel_input_CPUTime:" + CpuTime3 / 1000000f + "ms");
			System.out.println("javaCPUTime:" + (stopCpuTime  - startCpuTime) / 1000000f + "ms");
			System.out.println("CPUTime:" + ((stopCpuTime  - startCpuTime)+calc_k(CpuTime2)+CpuTime4[1]+CpuTime3) / 1000000f + "ms≒ about "+((((stopCpuTime  - startCpuTime)+calc_k(CpuTime2)+CpuTime4[1]+CpuTime3)/ 1000000f)/60000)+" minutes");

			//計測後はすべて即終了
			service.shutdownNow();
			service2.shutdownNow();
			for(int i=0;i<Y+3;i++){
		    	for(int j=0;j<W;j++){
		    		s[i][j].shutdownNow();
		    	}
			}

		}

		public static String mk_par(int[] x){//パラメータのjoin
			  String[] y = new String[x.length];
			  for(int i = 0; i < x.length; i++){
			    y[i] = String.valueOf(x[i]);
			  }
			return String.join(",",y);
		}

		public static long calc_k(long[][] x){//計算時間の最大値をreturnします
				long a = 0 , b = x[0][1];
				for (int i = 0; i< Y+2;i++){
					a = Math.max(a, x[i][1]);
				}
			return a;
		}

		public static long execute_cmd(String cmd) throws IOException{//cmd,powershell上でプログラムを起動。ログを取得。
			// TODO Auto-generated method stub
			String command = cmd;long diff=0;
			Pattern pat = Pattern.compile(".*: ([0-9]+).*");
			ProcessBuilder pb = new ProcessBuilder(command.split(" "));
			Process p = pb.start();
			p.getOutputStream().close();//powershell用

			BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
			String line;
			while ((line = br.readLine()) != null) {
			System.out.println(line);
			if (line.startsWith("Ticks")) {
				Matcher m = pat.matcher(line);
				m.matches();
					diff = Long.parseLong(m.group(1)+"00");
			}
			}
			br = new BufferedReader(new InputStreamReader(p.getErrorStream()));
			while ((line = br.readLine()) != null) {
			System.err.println(line);
			}
			return diff;

		}
		public static class Task implements Callable<String> {//終了次第即実行

		    String command; // パラメーターを保持
		    String res;
		    int loops;
		    int It,k,y,w;
		    long processtime;
		    ThreadMXBean tmxb = ManagementFactory.getThreadMXBean();
		    public Task(String command,int l,int[] params ) {
		        this.command = command;
		        this.loops = l;
		        this.It = params[0];//iteration
		        this.k = params[1];//thread operation
		        this.y = params[2];
		        if(params.length>=4)this.w = params[3];
		    }

		    @Override
		    public String call() throws Exception {
		    	if(this.It==-1){CpuTime3=tmxb.getThreadCpuTime(Thread.currentThread().getId());System.out.println("cputime3:"+CpuTime3);}
		    	if(this.It==0&&this.k==0&&CpuTime4[0]<=0){CpuTime4[0]=tmxb.getThreadCpuTime(Thread.currentThread().getId());System.out.println("cputime4[0]:"+CpuTime4[0]);}
		    	if(this.It>=1&&this.k==1&&CpuTime2[this.y+1][0]<=0){CpuTime2[this.y+1][0]=tmxb.getThreadCpuTime(Thread.currentThread().getId());System.out.println("cputime2["+(this.y+1)+"][0]:"+CpuTime2[this.y+1][0]);}
		        //Thread.sleep(3000);
		    	res="loop:"+this.loops+" y="+this.y;
		    	if(It!=-1){
		    		res="loop:"+this.loops+" Iteration="+this.It+" k="+this.k+" y="+this.y;
		    	}

		    	System.out.println("----------------------------------------------------------------------------start "+res+"----------------------------------------------------------------------------");
		    	processtime=execute_cmd(command);
		        System.out.println("task executed!"+this.command);
		        if(this.It==-1){CpuTime3=tmxb.getThreadCpuTime(Thread.currentThread().getId())-CpuTime3+processtime;System.out.println("cputime3:"+CpuTime3);}
		        if(this.It==0&&this.k==0){CpuTime4[1]+=tmxb.getThreadCpuTime(Thread.currentThread().getId())-CpuTime4[0]+processtime;System.out.println("cputime4[1]:"+CpuTime4[1]);}
		        if(this.It>=1&&this.k==1){CpuTime2[this.y+1][1]+=tmxb.getThreadCpuTime(Thread.currentThread().getId())-CpuTime2[this.y+1][0]+processtime;System.out.println("cputime2["+(this.y+1)+"][1]:"+CpuTime2[this.y+1][1]);}
		        System.out.println("-----------------------------------------------------------------------------fin "+res+"-----------------------------------------------------------------------------");
		        return "";
		    }
		}

		public static class Task_interval implements Callable<String> {//定期実行

		    String command; // パラメーターを保持
		    String res;
		    int loops;
		    int It,k,y,w,interval;
		    public Task_interval(String command,int l,int[] params,int interval) {
		        this.command = command;
		        this.loops = l;
		        this.It = params[0];//iteration
		        this.k = params[1];//thread operation
		        this.y = params[2];
		        this.interval = interval;
		        if(params.length>=4)this.w = params[3];
		    }

		    @Override
		    public String call() throws Exception {
		    	Thread.sleep(1000*interval);//インターバルをおく
		    	res="loop:"+this.loops+" y="+this.y;
		    	if(It!=-1){
		    		res="loop:"+this.loops+" Iteration="+this.It+" k="+this.k+" y="+this.y;
		    	}
		    	System.out.println("*****************************************************************************start "+res+"*****************************************************************************");
		    	execute_cmd(command);
		        System.out.println("task executed!"+this.command);
		        System.out.println("*****************************************************************************fin "+res+"*****************************************************************************");
		        if(this.y==-1){
		        System.out.println("Forfin NowTime:" + (System.nanoTime() - start) / 1000000f + " ms ≒ about "+(((System.nanoTime() - start) / 1000000f)/60000)+" minutes");
		        System.out.println("Forfin NowCPUTime:" + ((checkCpuTime  - startCpuTime)+calc_k(CpuTime2)+CpuTime4[1]+CpuTime3) / 1000000f + "ms≒ about "+((((checkCpuTime  - startCpuTime)+calc_k(CpuTime2)+CpuTime4[1]+CpuTime3)/ 1000000f)/60000)+" minutes");
		        }
		        return "";
		    }
		}
}