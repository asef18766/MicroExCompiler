#include "libcpp.h"
#include "statement.h"

#include <queue>
#include <string>
#include <string.h>
#include <iostream>
#include <map>
#include <stdexcept>
#include <regex>

#define RET_IS_FLOAT(v0, v1) v0 == "float" || v1 == "float"

extern void push_instruction();
namespace var_container
{
    struct var_con
    {
        std::string name;
        int arrsz;
    };
    std::queue<var_con> *instance = nullptr;
    std::map<std::string, std::string> *var_maps = nullptr;
    std::map<std::string, std::string> *tmp_maps = nullptr;
    std::string last_store_name = "";
    void init_instatce()
    {
        if (var_container::instance == nullptr)
        {
            var_container::instance = new std::queue<var_container::var_con>();
            var_container::var_maps = new std::map<std::string, std::string>();
            var_container::tmp_maps = new std::map<std::string, std::string>();
        }
    }
} // namespace var_container
void insert_var(char *str)
{
    var_container::init_instatce();
    var_container::instance->push({str, 0});
}
void insert_array(char *str)
{
    var_container::init_instatce();
    char name[8787] = {0};
    int cnt = 0;
    sscanf(str, "%[^[][%d]", name, &cnt);
    var_container::instance->push({name, cnt});
}
char *gen_var_code(char *type)
{
    std::string res = "";
    while (!var_container::instance->empty())
    {
        auto it = var_container::instance->front();
        var_container::instance->pop();
        char line[48763] = {0};

        if (it.arrsz == 0)
            sprintf(line, "Declare %s, %s\n", it.name.c_str(), type);
        else
            sprintf(line, "Declare %s, %s_array, %d\n", it.name.c_str(), type, it.arrsz);
        (*var_container::var_maps)[it.name] = type;
        res += line;
    }
    return strdup(res.c_str());
}
char* allocate_tmp(bool isfloat)
{
    var_container::init_instatce();

    static int num = 0;
    num++;
    
    char name[87] = {0};
    sprintf(name, "T&%d", num);
    (*var_container::tmp_maps)[name] = isfloat? "float":"integer";
    return strdup(name);

}
std::string strip_bracket(std::string it)
{
    size_t pos = it.find('[');
    if (pos != std::string::npos)
    {
        return it.substr(0, (int)pos);
    }
    return it;
}
std::string get_object_type(std::string it)
{
    it = strip_bracket(it);
    if (var_container::var_maps->find(it) == var_container::var_maps->end())
    {
        if (var_container::tmp_maps->find(it) == var_container::tmp_maps->end())
        {
            std::regex int_reg("[0-9]+");
            std::regex float_reg("(0|([1-9][0-9]*))\.[0-9]*");
            
            if (std::regex_match(it, int_reg))
                return "integer";
            if (std::regex_match(it, float_reg))
                return "float";
            
            throw std::invalid_argument(it);
        }
        return (*var_container::tmp_maps)[it];
    }
    return (*var_container::var_maps)[it];
}
char* calc_ops(char *var0, char *var1, CALC_OPS op)
{
    switch (op)
    {
        case CALC_OPS::ADD:
        case CALC_OPS::SUB:
        case CALC_OPS::MUL:
        case CALC_OPS::DIV:
        {
            auto v0t = get_object_type(var0);
            auto v1t = get_object_type(var1);

            bool res_type = RET_IS_FLOAT(v0t, v1t);
            auto ret = allocate_tmp(res_type);

            const char* ops[]={
                "ADD",
                "SUB",
                "MUL",
                "DIV"
            };
            char ins[8787] = {0};
            sprintf(ins, "%s %s,%s,%s", ops[op], var0, var1, ret);
            std::string str = (res_type? "F_":"I_");
            str+=ins;
            statement::push_instruction(str);
            return ret;
        }
        case CALC_OPS::CMP:
        {
            auto v0t = get_object_type(var0);
            auto v1t = get_object_type(var1);

            bool res_type = RET_IS_FLOAT(v0t, v1t);

            char ins[8787];
            sprintf(ins, res_type? "F_CMP %s, %s":"I_CMP %s, %s", var0, var1);
            statement::push_instruction(ins);
            return NULL;
        }
        case CALC_OPS::STORE:
        {
            auto v1t = get_object_type(var1);
            bool res_type = v1t == "float";
            var_container::last_store_name = var0;

            char ins[8787];
            sprintf(ins, res_type? "F_STORE %s, %s":"I_STORE %s, %s", var1, var0);
            statement::push_instruction(ins);
            return NULL;
        }
        case CALC_OPS::NEG:
        {
            auto v0t = get_object_type(var0);
            bool res_type = v0t == "float";
            auto ret = allocate_tmp(res_type);

            char ins[8787] = {0};
            sprintf(ins, res_type? "F_UMINUS %s, %s":"I_UMINUS %s, %s", var0, ret);
            statement::push_instruction(ins);
            return ret;
        }
        case CALC_OPS::INC:
        {
            char ins[8787] = {0};
            sprintf(ins, "INC %s", var0);
            statement::push_instruction(ins);
            return NULL;
        }
        default:
            throw std::invalid_argument("invaild input of op argument");
            break;
    }
}
char* get_last_store()
{
    return strdup(var_container::last_store_name.c_str());
}