byte N = 5;
byte A[N] = {1, 2, 3, 4, 5}; 
bool locked[N] = {false, false, false, false, false};




active [N] proctype P() {
 	byte temp;
	byte i = _pid;
	byte j = _pid;
	do
		:: j < (N-1) -> j = j +1;
		:: j > 0 -> j = j -1;
		:: break;
	od;
	trying:
	do
		:: atomic {printf("pid = %d j = %d\n", i, j);
			if
				:: !locked[i] && !locked[j] ->locked[i] = true;
					locked[j] = true;
					break;
				:: else
			fi;}
	od;
	critical:
	temp = A[i]
	A[j] = A[i]
	A[i] = temp
	atomic{
		locked[i] = false
		locked[j] = false
	}
	
	
}