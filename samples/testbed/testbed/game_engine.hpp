class GameMod {
public:
    GameMod(lua_State *lstat) : running_(true), L(lstat) {}
    virtual void init() {}
    virtual bool running() const {return running_;}
    virtual void update() {}

protected:
    virtual void end() {running_ = false;}
    lua_State *L;

private:
    bool running_;
};

int game_main(int, char**, GameMod*);
