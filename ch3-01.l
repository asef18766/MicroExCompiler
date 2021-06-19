%{
    #include "common.h"
    #include "y.tab.h"
%}

%{
/*
 * this sample demonstrates (very) simple recognition:
 * a verb/not a verb.
 */
int linecounter = 1;
%}
%%
[\t ]+ {}
[Pp][Rr][Oo][Gg][Rr][Aa][Mm] {return TOKEN_PROGRAM;}
[Bb][Ee][Gg][Ii][Nn] {return TOKEN_BEGIN;}
[Ee][Nn][Dd] {return TOKEN_END;}
READ {return TOKEN_READ;}
WRITE {return TOKEN_WRITE;}
(0|([1-9][0-9]*))\.[0-9]* {yylval.string = strdup(yytext);return TOKEN_FLOAT_LIT;}
(0|([1-9][0-9]*))\.[0-9]*[Ee][\+-]?[1-9][0-9]* {return TOKEN_EXP_LIT;}
[0-9]+ {yylval.string = strdup(yytext);return TOKEN_INT_LIT;}
\".*\" {return TOKEN_STR_LIT;}
\( {return TOKEN_LP;}
\) {return TOKEN_RP;}
; {return TOKEN_SEMICLON;}
, {return TOKEN_COMMA;}
:= {return TOKEN_ASSIGN;}
\+ {return TOKEN_PLUS;}
- {return TOKEN_MINUS;}
\* {return TOKEN_MUL;}
\/ {return TOKEN_DIV;}
!= {return TOKEN_NE;}
> {return TOKEN_GT;}
\< {return TOKEN_LT;}
>= {return TOKEN_GE;}
\<= {return TOKEN_LE;}
== {return TOKEN_EQ;}
IF {return TOKEN_IF;}
THEN {return TOKEN_THEN;}
ELSE {return TOKEN_ELSE;}
ENDIF {return TOKEN_ENDIF;}
FOR {return TOKEN_FOR;}
TO {return TOKEN_TO;}
ENDFOR {return TOKEN_ENDFOR;}
WHILE {return TOKEN_WHILE;}
ENDWHILE {return TOKEN_ENDWHILE;}
[Dd][Ee][Cc][Ll][Aa][Rr][Ee] {return TOKEN_DECLARE;}
AS|as {return TOKEN_AS;}
INTEGER|integer {yylval.string = strdup(yytext);return TOKEN_INTEGER;}
REAL|real {yylval.string = strdup(yytext);return TOKEN_REAL;}
[Ff][Ll][Oo][Aa][Tt] {yylval.string = strdup(yytext);return TOKEN_REAL;}
STRING {return TOKEN_STRING;}
[a-zA-z][a-zA-z0-9_]*\[[0-9]+\] {
    yylval.string = strdup(yytext);
    return TOKEN_ARRAY;
}
[a-zA-z][a-zA-z0-9_]* {
    yylval.string = strdup(yytext);
    return TOKEN_ID;
}
\%\%.*\n {linecounter++;}
\n {linecounter++;}
.  { printf("got unexpected token [%s]\n", yytext);return TOKEN_UNEXPECTED; }
%%