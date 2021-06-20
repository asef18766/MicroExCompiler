START testP
Declare I, integer
Declare A, float
Declare B, float
Declare C, float
Declare D, float
Declare LLL, float_array, 100
F_CMP A, 10000.0
JL lb&1
F_ADD A,3.14,T&1
CALL print,T&1
J lb&2
lb&1:CALL print,2,1.4
lb&2:HALT testP
