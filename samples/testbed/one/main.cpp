#include <game_engine.hpp>

int main(int argc, char **argv) {
    LuaGameEngine engine;

    game_main(argc, argv, &engine);
}
