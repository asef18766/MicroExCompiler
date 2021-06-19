#pragma once
#ifdef __cplusplus
extern "C" 
{
#else
#include <stdbool.h>
#endif
    typedef enum {
        ADD = 0,
        SUB,
        MUL,
        DIV,
        NEG,
        STORE,
        INC,
        CMP
    } CALC_OPS;
    void insert_var(char* str);
    void insert_array(char* str);
    char* gen_var_code(char *type);

    /* return tmp variable names */
    char* calc_ops(char *var0, char *var1, CALC_OPS op);
    char* get_last_store();

    char* dump_statements();

    void push_for(char *init, char *inc);
    char** pop_for();

#ifdef __cplusplus
}
#endif