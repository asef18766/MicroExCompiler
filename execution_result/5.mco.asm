START testP
Declare I, integer
Declare A, float
Declare B, float
Declare C, float
Declare D, float
Declare LLL, float_array, 100
I_STORE 1, I
lb&1:F_UMINUS LLL[I], T&1
F_MUL B,D,T&2
F_ADD T&1,T&2,T&3
F_SUB T&3,C,T&4
F_STORE T&4, A
INC I
I_CMP I, 100
JL lb&1
F_CMP A, 10000.0
JL lb&2
F_ADD A,3.14,T&5
CALL print,T&5
J lb&3
lb&2:CALL print,2,1.4
lb&3:HALT testP
