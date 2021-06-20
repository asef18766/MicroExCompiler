%{
        #include "common.h"
        #include "libcpp/libcpp.h"

        extern int yylex();
        extern int linecounter;
        int yyerror(const char* msg)
        {
                printf("Error: %s encountered at line number:%d\n", msg, linecounter);
        }
%}
%code requires {
    struct cmp_ops {
        char *op;
        char *init;
    };
}
%union {
    char *string;
    struct cmp_ops ops;
}

%define parse.error verbose
%token TOKEN_BEGIN
%token TOKEN_END
%token TOKEN_READ
%token TOKEN_WRITE
%token TOKEN_INT_LIT
%token TOKEN_ID
%token TOKEN_FLOAT_LIT
%token TOKEN_EXP_LIT
%token TOKEN_STR_LIT
%token TOKEN_LP
%token TOKEN_RP
%token TOKEN_SEMICLON
%token TOKEN_COMMA
%token TOKEN_ASSIGN
%token TOKEN_PLUS
%token TOKEN_MINUS
%token TOKEN_MUL
%token TOKEN_DIV
%token TOKEN_NE
%token TOKEN_GT
%token TOKEN_LT
%token TOKEN_GE
%token TOKEN_LE
%token TOKEN_EQ
%token TOKEN_IF
%token TOKEN_THEN
%token TOKEN_ELSE
%token TOKEN_ENDIF
%token TOKEN_FOR
%token TOKEN_TO
%token TOKEN_ENDFOR
%token TOKEN_WHILE
%token TOKEN_ENDWHILE
%token TOKEN_DECLARE
%token TOKEN_AS
%token TOKEN_INTEGER
%token TOKEN_REAL
%token TOKEN_STRING
%token TOKEN_ENDLINE
%token TOKEN_COMMENT
%token TOKEN_UNEXPECTED
%token TOKEN_PROGRAM
%token TOKEN_ARRAY

%type <string> TOKEN_REAL
%type <string> TOKEN_INTEGER

%type <string> TOKEN_ID
%type <string> TOKEN_ARRAY

%type <string> variable
%type <string> var_types

%type <string> statement_list
%type <string> statement
%type <string> declare_statement
%type <string> for_statement
%type <string> assignment_statement
%type <string> if_statement
%type <string> function_statement

%type <string> cal_unit
%type <string> calculation

%type <string> TOKEN_FLOAT_LIT
%type <string> TOKEN_INT_LIT

%type <string> arguments
%type <string> assignment
%type <ops> comparison
%type <string> for_init
%type <string> com_ops

%type <string> TOKEN_GT
%type <string> TOKEN_LT
%type <string> TOKEN_GE
%type <string> TOKEN_LE
%type <string> TOKEN_NE
%type <string> TOKEN_EQ


%left TOKEN_PLUS TOKEN_MINUS
%right TOKEN_MUL TOKEN_DIV
%nonassoc UMINUS

%%
program:        TOKEN_PROGRAM TOKEN_ID TOKEN_BEGIN statement_list  TOKEN_END <<EOF>> {
        printf("START %s\n%sHALT %s\n", $2, $4, $2);
}
;
statement_list: statement statement_list {
        int sz = strlen($1)+strlen($2)+1;
        char* stmt = malloc(sz);
        memset(stmt, 0, sz);
        strcat(stmt, $1);
        strcat(stmt, $2);
        $$=stmt;
}
        |       statement
;
statement: declare_statement {$$=$1;}
        |  for_statement {$$=$1;}
        |  assignment_statement {$$=$1;}
        |  if_statement {$$=$1;}
        |  function_statement {$$=$1;}
;
declare_statement: TOKEN_DECLARE variables TOKEN_AS var_types TOKEN_SEMICLON { 
        $$ = gen_var_code($4);
}
;
var_types:      TOKEN_INTEGER {$$=$1;}
        |       TOKEN_REAL    {$$=$1;}
;
variables:      variable TOKEN_COMMA variables
        |       variable
;
variable:       TOKEN_ID    { insert_var($1); }
        |       TOKEN_ARRAY { insert_array($1); }
;
for_statement:  TOKEN_FOR TOKEN_LP for_init TOKEN_RP statement_list TOKEN_ENDFOR {
        char **st = pop_for();
        int sz = strlen(st[1])+ \
                 strlen(st[0])+ \
                 strlen($5)+ \
                 strlen(st[2])+2;
        char* stmt = malloc(sz);
        memset(stmt, 0, sz);
        strcat(stmt, st[1]);
        strcat(stmt, st[0]);
        stmt[strlen(st[1])+strlen(st[0])] = ':';
        strcat(stmt, $5);
        strcat(stmt, st[2]);
        $$=stmt;
}
;
for_init: assignment TOKEN_TO TOKEN_INT_LIT {
        char* ptr_name = get_last_store();
        calc_ops(ptr_name, NULL, INC);
        calc_ops(ptr_name, $3, CMP);
        
        char *tmp= dump_statements();
        push_for($1, tmp);
        free(tmp);
        
}
;
assignment:TOKEN_ID TOKEN_ASSIGN calculation {
        calc_ops($1, $3, STORE);
        $$ = dump_statements();
}
;
assignment_statement:assignment TOKEN_SEMICLON {
        $$ = $1;
}
;
calculation:cal_unit {$$=$1;}
|       calculation TOKEN_PLUS calculation {
                $$ = calc_ops($1, $3, ADD);
        }
|       calculation TOKEN_MINUS calculation {
                $$ = calc_ops($1, $3, SUB);
        }
|       calculation TOKEN_MUL calculation {
                $$ = calc_ops($1, $3, MUL);
        }
|       calculation TOKEN_DIV calculation {
                $$ = calc_ops($1, $3, DIV);
        }
|       TOKEN_MINUS calculation %prec UMINUS {
                $$ = calc_ops($2, NULL, NEG);
        }
;
cal_unit: TOKEN_ID {$$=$1;}
        | TOKEN_ARRAY {$$=$1;}
        | TOKEN_INT_LIT {$$=$1;}
        | TOKEN_FLOAT_LIT {$$=$1;}
;
if_statement: TOKEN_IF TOKEN_LP comparison TOKEN_RP TOKEN_THEN statement_list TOKEN_ENDIF {
                //asdasd
                printf("short if~~\n");
        }
            | TOKEN_IF TOKEN_LP comparison TOKEN_RP TOKEN_THEN statement_list TOKEN_ELSE statement_list TOKEN_ENDIF {                
                char *lab_f = create_label();
                char *lab_e = create_label();
                char cmp[8787];
                char cmp2[8787];
                sprintf(cmp, "%s\n", jmp_inv($3.op, lab_f));
                sprintf(cmp2, "%s\n", jmp_ops("", lab_e));
                
                char res[48763];
                memset(res, 0, 48763);

                strcat(res, $3.init);
                strcat(res, cmp);
                strcat(res, $6);
                strcat(res, cmp2);
                strcat(res, lab_f);
                strcat(res, ":");
                strcat(res, $8);
                strcat(res, lab_e);
                strcat(res, ":");
                
                $$=strdup(res);
        }
;
comparison: calculation com_ops calculation {
        calc_ops($1, $3, CMP);
        $$.op = strdup($2);
        $$.init = dump_statements();
}
;
com_ops: TOKEN_LT {$$=$1;}
       | TOKEN_GT {$$=$1;}
       | TOKEN_LE {$$=$1;}
       | TOKEN_GE {$$=$1;}
       | TOKEN_NE {$$=$1;}
       | TOKEN_EQ {$$=$1;}
;
function_statement: TOKEN_ID TOKEN_LP arguments TOKEN_RP TOKEN_SEMICLON
{
        char* st= dump_statements();
        char* res = malloc(
                strlen(st)+\
                strlen("CALL ")+\
                strlen($1)+\
                strlen(",")+\
                strlen($3)+\
                strlen("\n"));
        strcat(res, st);
        strcat(res, "CALL ");
        strcat(res, $1);
        strcat(res, ",");
        strcat(res, $3);
        strcat(res, "\n");
        $$=res;
}
;
arguments: calculation TOKEN_COMMA arguments
{
        int slen = strlen($1)+strlen($3)+2;
        char* res = malloc(slen);
        memset(res, 0, slen);
        strcat(res, $1);
        strcat(res, ",");
        strcat(res, $3);
        $$=res;
}
|          calculation {$$=$1;}
;