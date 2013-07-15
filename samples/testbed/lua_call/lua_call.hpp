#include "../testbed/game_engine.hpp"

class Test_LuaCall : public GameMod {
public:
    Test_LuaCall(lua_State *lstat) : GameMod(lstat) {}
    void init();
};
