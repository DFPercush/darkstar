#pragma once

#include <string>

const char* shell_arg_cstr(const char* name);
inline const char* shell_arg(const char* name) { return shell_arg_cstr(name); }
bool shell_arg_present(const char* name);
void set_shell_arg(const char* name, const char* val, bool used = false); // used: Already acknowledged as a valid option by calling module.
const std::string& shell_arg_std_string(const std::string& name);
inline const std::string& shell_arg(const std::string& name) { return shell_arg_std_string(name); }
bool shell_arg_present(const std::string& name);
std::string unused_shell_args(); // For reporting warnings, usually upon exit.