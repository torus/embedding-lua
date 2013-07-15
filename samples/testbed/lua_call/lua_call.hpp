#include "game_engine.hpp"

class Test_LuaCall : public TestBase {
public:
    Test_LuaCall(lua_State *lstat) : TestBase(lstat) {}
    void init();
};
