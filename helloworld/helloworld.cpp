//~~<<includes
#include <iostream>
#include <lua.hpp>
//~~>>

//~~<<cppfunc
int luafunc_hello(lua_State *L)
{
    const char *str = lua_tostring(L, -1);
    std::cout << "Hello, " << str << "!" << std::endl;
    return 0;
}
//~~>>

//~~<<prepare
int main(int argc, char **argv)
{
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
//~~>>

    // C++ -> Lua
//~~<<cpp2lua
    lua_getglobal(L, "print");
    lua_pushstring(L, "Hello, World!");
    if (lua_pcall(L, 1, 0, 0)) {
        std::cerr << "Lua Error: " << lua_tostring(L, -1) << std::endl;
    }
//~~>>

    // Lua -> C++
//~~<<register
    lua_register(L, "hello", luafunc_hello);
//~~>>
//~~<<lua2cpp
    if (luaL_dostring(L, "hello('Lua')")) {
        std::cerr << "Lua Error: " << lua_tostring(L, -1) << std::endl;
    }

    return 0;
}
//~~>>
