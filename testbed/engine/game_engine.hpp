#include <exception>
#include <string>
#include <lua.hpp>

class GameMod {
public:
    GameMod() : running_(true) {}
    virtual void init() {}
    virtual bool running() const {return running_;}
    virtual void update(double elapsed) {}
    virtual ~GameMod() {}

protected:
    virtual void end() {running_ = false;}

private:
    bool running_;
};

int game_main(int, char**, GameMod*);

///

class LuaException : public std::exception {
public:
    LuaException(const char *err) throw() : err_(err), std::exception() {}
    ~LuaException() throw() {}
    const char* what() const throw() {return err_.c_str();}

private:
    std::string err_;
};

class LuaGameEngine : public GameMod {
public:
    LuaGameEngine();
    void init();
    void update(double elapsed);
    bool running() const;
    lua_State* luaState() const {return L;}

    void dieIfFail(int state) const;

private:
    class StackCleaner {
    public:
        StackCleaner(lua_State *stat) : L(stat) {}
        ~StackCleaner() {
            lua_settop(L, 0);
        }
    private:
        lua_State *L;
    };
    lua_State *L;
    int gameState_;
};
