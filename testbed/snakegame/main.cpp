//~~<<includes
#include <ctime>
#include <cmath>
#include <boost/timer/timer.hpp>
#include <game_engine.hpp>
//~~>>

//~~<<sleep
extern "C" int luafunc_sleep(lua_State *L)
{
    double duration = lua_tonumber(L, 1);
    time_t sec = floor(duration);
    long nanosec = (duration - sec) * 1000000000L;
    struct timespec sp = {sec, nanosec};
    nanosleep(&sp, NULL);

    return 0;
}
//~~>>

//~~<<elapsed_time
static boost::timer::cpu_timer timer;

extern "C" int luafunc_elapsed_time(lua_State *L)
{
    boost::timer::nanosecond_type elapsed = timer.elapsed().wall;
    double sec = elapsed / 1000000000.;
    lua_pushnumber(L, sec);

    return 1;
}
//~~>>

//~~<<main
int main(int argc, char **argv) {
    LuaGameEngine engine;

    lua_register(engine.luaState(), "sleep", luafunc_sleep);
    lua_register(engine.luaState(), "elapsed_time", luafunc_elapsed_time);
    game_main(argc, argv, &engine);
}
//~~>>
