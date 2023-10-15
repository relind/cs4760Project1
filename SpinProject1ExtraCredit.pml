byte N = 5;
byte A[N]; 
bool locked[N];
bool cycle[N];

/* Used to determine of the cycle is ready to start */
bool cycleReady;



active [N] proctype P() {
 	byte temp;
	byte i = _pid;
	byte j = _pid;
	byte index = 0;



	/* if the pid is equal to 0, then initialize all arrays */
	if
		:: atomic{i == 0 ->
			do
				:: index < N; 
					A[index] = index+1;
					locked[index] = false;
					cycle[index] = false;
					index = index + 1
				:: else -> break
			od;
			cycleReady = true;
			index = 0;
			};
		:: else 
	fi;



	/* This is where the cycle loops back to when all processes have completed their work for the cycle*/
	startCycle:
	
	do
		:: cycleReady -> break
		:: else
	od;
	
	/* generate random number j by incrementing/decrementing from j = (pid + 1) */
	do
		:: j < (N-1) -> j = j +1;
		:: j > 0 -> j = j -1;
		:: break;
	od;

	/* trying to get the mutex */
	trying:
	do
		:: atomic{(!locked[i] && !locked[j]) -> locked[i] = true; locked[j] = true; break }
		:: else
	od;

	/* critical section */
	critical:
	temp = A[i];
	A[i] = A[j];
	A[j] = temp;
	cycle[i] = true;
	atomic{
	locked[i] = false;
	locked[j] = false;}
	/* this next section checks if the cycle is complete
	    to ensure that all processes don't constantly go through this loop,
	    we anly allow process with (pid = 0) to check if all processes have completed the cycle */
	if
		:: i == 0 -> do
			:: atomic{
				/* set cycle to true, iterate through the cycle to determine if all processes are ready 
				   in atomic statement so other processes don't read cycleReady until it has been 
				   fully checked*/
				cycleReady = true;
				do
					:: else -> index = index + 1;
					:: !(index > N) ->
						if 
							::cycle[index] == false -> cycleReady = false; break
						fi;
					:: index == N -> break;
				od;
				index = 0;
				if
					:: cycleReady == true -> goto startCycle;
					:: else
				fi;
			};
		od;
		:: else -> goto startCycle
	fi;		

}

#define jVal1 P[0]:j
#define jVal2 P[1]:j
#define jVal3 P[2]:j
#define jVal4 P[3]:j
#define jVal5 P[4]:j

#define c1 P[0]@critical
#define c2 P[1]@critical
#define c3 P[2]@critical
#define c4 P[3]@critical
#define c5 P[4]@critical

#define mutex1and2 ((jVal2 == 0) && c2 && c1)
#define mutex1and3 ((jVal3 == 0) && c3 && c1)
#define mutex1and4 ((jVal4 == 0) && c4 && c1)
#define mutex1and5 ((jVal5 == 0) && c5 && c1)

#define mutex2and1 ((jVal1 == 1) && c1 && c2)
#define mutex2and3 ((jVal3 == 1) && c3 && c2)
#define mutex2and4 ((jVal4 == 1) && c4 && c2)
#define mutex2and5 ((jVal4 == 1) && c5 && c2)

#define mutex3and1 ((jVal1 == 2) && c1 && c3)
#define mutex3and2 ((jVal2 == 2) && c2 && c3)
#define mutex3and4 ((jVal4 == 2) && c4 && c3)
#define mutex3and5 ((jVal5 == 2) && c5 && c3)

#define mutex4and1 ((jVal1 == 3) && c1 && c4)
#define mutex4and2 ((jVal2 == 3) && c2 && c4)
#define mutex4and3 ((jVal3 == 3) && c3 && c4)
#define mutex4and5 ((jVal5 == 3) && c4 && c4)

#define mutex5and1 ((jVal1 == 4) && c1 && c5)
#define mutex5and2 ((jVal2 == 4) && c2 && c5)
#define mutex5and3 ((jVal3 == 4) && c3 && c5)
#define mutex5and4 ((jVal4 == 4) && c4 && c5)

#define mutex1 (mutex1and2 && mutex1and3 && mutex1and4 && mutex1and5)
#define mutex2 (mutex2and1 && mutex2and3 && mutex2and4 && mutex2and5)
#define mutex3 (mutex3and1 && mutex3and2 && mutex3and4 && mutex3and5)
#define mutex4 (mutex4and1 && mutex4and2 && mutex4and3 && mutex4and5)
#define mutex5 (mutex5and1 && mutex5and2 && mutex5and3 && mutex5and4)

#define allmutex (mutex1 && mutex2 && mutex3 && mutex4 && mutex5)



ltl {[] !(allmutex)}