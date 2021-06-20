#include "libcpp.h"
#include "statement.h"
#include <vector>
#include <string>
#include <string.h>
#include <iostream>
#include <stack>
#include <tuple>

namespace statement
{
    std::vector<std::string> *instance = nullptr;
    std::stack<std::tuple<std::string, std::string, int> > *for_stack = nullptr;
    void init_instace()
    {
        if (instance == nullptr)
        {
            instance = new std::vector<std::string>();
            for_stack = new std::stack<std::tuple<std::string, std::string, int> >();
        }
    }
    void push_instruction(std::string str)
    {
        init_instace();
        instance->push_back(str);
    }
}
char* dump_statements()
{
    statement::init_instace();
    auto rec = statement::instance;
    auto sz = rec->size();
    std::string res;
    for (auto i = 0; i != sz ; i++)
    {
        res += (*rec)[i];
        res += '\n';
    }
    auto ptr = strdup(res.c_str());
    rec->clear();   
    return ptr;
}
int get_label()
{
    static int ctr = 0;
    ctr++;
    return ctr;
}
void push_for(char *init, char *inc)
{
    int ctr = get_label();
    statement::init_instace();
    statement::for_stack->push(std::make_tuple(std::string(init), std::string(inc), ctr));
}
char** pop_for()
{
    char **arr = (char **)malloc(sizeof(char*)*4);
    auto top = statement::for_stack->top();statement::for_stack->pop();

    char* strbuf = (char*)malloc(87);
    memset(strbuf, 0, 87);
    int num = std::get<2>(top);
    sprintf(strbuf, "lb&%d", num);
    arr[0] = strbuf;

    arr[1] = strdup(std::get<0>(top).c_str()); // init
    
    auto end = std::get<1>(top);
    end += "JL ";
    end += arr[0];
    end += '\n';
    arr[2] = strdup(end.c_str());

    return arr;
}
char* create_label()
{
    char buf[87] = {0};
    sprintf(buf, "lb&%d", get_label());
    return strdup(buf);
}