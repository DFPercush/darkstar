#include "../common/shellargs.h"
#include <unordered_map>

struct shell_arg_second_t
{
    std::string val;
    bool used;
};

// Module wide Globals, not exposed to other .cpp files
std::unordered_map<std::string, shell_arg_second_t> mg_shellArgs;

const std::string& shell_arg_std_string(const std::string& name)
{
    static const std::string nulstr{ "" };
    auto res = mg_shellArgs.find(name);
    if (res == mg_shellArgs.end())
        return nulstr;
    res->second.used = true;
    return res->second.val;
}

const char* shell_arg_cstr(const char* name)
{
    return shell_arg_std_string(name).c_str();
}

bool shell_arg_present(const char* name)
{
    std::string ns{ name };
    return shell_arg_present(ns);
}

bool shell_arg_present(const std::string& name)
{
    auto res = mg_shellArgs.find(name);
    bool ret = (!(res == mg_shellArgs.end()));
    if (ret)
        res->second.used = true;
    return ret;
}

void set_shell_arg(const char* name, const char* val, bool used)
{
    shell_arg_second_t s;
    s.val = val;
    s.used = used;
    mg_shellArgs[name] = s;
}

std::string unused_shell_args()
{
    std::string ret;
    for (auto x : mg_shellArgs)
    {
        if (!x.second.used)
        {
            if (ret.length() > 0)
                ret += ",";
            ret += x.first;
        }
    }
    return ret;
}