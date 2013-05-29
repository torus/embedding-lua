#include <lua.hpp>

int main(int argc, char **argv) {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    if (luaL_dofile(L, "hello.lua")) {
	fprintf(stderr, "Lua Error: %s", lua_tostring(L, -1));
    }

    lua_getglobal(L, "greeting");
    if (lua_pcall(L, 0, 0, 0)) {
        fprintf(stderr, "Lua Error: %s\n", lua_tostring(L, -1));
    }

    return 0;
}
