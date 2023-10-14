byte N = 5;
byte A[N]; 
bool locked[N];
bool cycle[N];

/* Used to determine of the cycle is ready to start */
bool cycleReady;
	
active [N] proctype P() {
 	byte temp;
	byte i = _pid;
	byte j = _pid + 1;
	byte index = 0;
	
	/* if the pid is equal to 0, then initialize all arrays */
	if
		:: atomic{i == 0 ->
			do
				:: A[index] = index+1;
					locked[index] = false;
					cycle[index] = false;
					index = index + 1
				:: index == N -> break
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
		:: atomic{ (!locked[i] && !locked[j]) -> locked[i] = true; locked[j] = true; break }
		:: else
	od;

	/* critical section */
	critical:
	temp = A[i];
	A[i] = A[j];
	A[j] = temp;
	cycle[i] = true;
	locked[i] = false;
	locked[j] = false;
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
					:: cycle[index] == false -> cycleReady = false; break
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

