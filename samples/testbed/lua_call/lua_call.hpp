class TestBase {
public:
    TestBase(lua_State *lstat) : running_(true), L(lstat) {}
    virtual void init() {}
    virtual bool running() const {return running_;}
    virtual void update() {}

protected:
    virtual void end() {running_ = false;}
    lua_State *L;

private:
    bool running_;
};

class Test_LuaCall : public TestBase {
public:
    Test_LuaCall(lua_State *lstat) : TestBase(lstat) {}
    void init();
};
