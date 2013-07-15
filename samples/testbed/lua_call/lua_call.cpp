#include <iostream>
#include <lua.hpp>

#include "lua_call.hpp"

void Test_LuaCall::init()
{
    luaL_dofile(L, "lua_call.lua");

    lua_getglobal(L, "f");                  /* function to be called */
    lua_pushstring(L, "how");                        /* 1st argument */
    lua_getglobal(L, "t");                    /* table to be indexed */
    lua_getfield(L, -1, "x");        /* push result of t.x (2nd arg) */
    lua_remove(L, -2);                  /* remove 't' from the stack */
    lua_pushinteger(L, 14);                          /* 3rd argument */
    lua_call(L, 3, 1);     /* call 'f' with 3 arguments and 1 result */
    lua_setglobal(L, "a");                         /* set global 'a' */

    lua_getglobal(L, "a");
    const char *str = lua_tostring(L, -1);
    std::cout << "a = " << str << std::endl;

    end();
}

int main(int argc, char **argv) {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    return game_main(argc, argv, new Test_LuaCall(L));
}
