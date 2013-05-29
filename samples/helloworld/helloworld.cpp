#include <lua.hpp>

int main(int argc, char **argv) {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    if (luaL_loadfile(L, "hello.lua")) {
	fprintf(stderr, "Lua Error: %s", lua_tostring(L, -1));
    }

    lua_getglobal(L, "greeting");
    lua_call(L, 0, 0);
}
