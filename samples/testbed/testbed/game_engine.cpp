#include <new>
#include <iostream>
#include <boost/timer/timer.hpp>
#include "game_engine.hpp"

int game_main(int argc, char **argv, GameMod *t) {
    t->init();
    boost::timer::cpu_timer timer;
    boost::timer::nanosecond_type prev_time = 0;

    while (t->running()) {
        boost::timer::nanosecond_type elapsed = timer.elapsed().wall;
	t->update((elapsed - prev_time) / 1000000000.0);
        prev_time = elapsed;
    }

    return 0;
}

////

extern "C" int luaopen_nc(lua_State*);

LuaGameEngine::LuaGameEngine() : GameMod(), L(luaL_newstate()), gameState_(0)
{
    luaL_openlibs(L);
    luaopen_nc(L);
    dieIfFail(luaL_dofile(L, "bootstrap.lua"));
}

void LuaGameEngine::dieIfFail(int state) const
{
    if (state) {
        const char *err = lua_tostring(L, -1);
        throw LuaException(err);
    }
}

void LuaGameEngine::init()
{
    StackCleaner cleaner(L);

    lua_getglobal(L, "init");
    dieIfFail(lua_pcall(L, 0, 1, 0));
    gameState_ = luaL_ref(L, LUA_REGISTRYINDEX);
}

void LuaGameEngine::update(double elapsed)
{
    StackCleaner cleaner(L);

    lua_getglobal(L, "update");
    lua_rawgeti(L, LUA_REGISTRYINDEX, gameState_);
    lua_pushnumber(L, elapsed);
    dieIfFail(lua_pcall(L, 2, 0, 0));
}

bool LuaGameEngine::running() const
{
    StackCleaner cleaner(L);

    lua_getglobal(L, "running");
    lua_rawgeti(L, LUA_REGISTRYINDEX, gameState_);
    dieIfFail(lua_pcall(L, 1, 1, 0));

    int is_running = lua_toboolean(L, 1);
    return is_running == 1;
}
