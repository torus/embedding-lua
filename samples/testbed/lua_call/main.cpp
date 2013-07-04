#include <lua.hpp>

#include "lua_call.hpp"

int main(int argc, char **argv) {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    Test_LuaCall *t = new Test_LuaCall(L);
    t->init();

    while (t->running()) {
	t->update();
    }
}
