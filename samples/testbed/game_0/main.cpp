#include <ctime>
#include <cmath>
#include <game_engine.hpp>

extern "C" int luafunc_sleep(lua_State *L)
{
    double duration = lua_tonumber(L, 1);
    time_t sec = floor(duration);
    long nanosec = (duration - sec) * 1000000000L;
    struct timespec sp = {sec, nanosec};
    nanosleep(&sp, NULL);

    return 0;
}

int main(int argc, char **argv) {
    LuaGameEngine engine;

    lua_register(engine.luaState(), "sleep", luafunc_sleep);
    game_main(argc, argv, &engine);
}
