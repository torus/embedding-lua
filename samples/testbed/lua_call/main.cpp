#include <lua.hpp>
#include "game_engine.hpp"

int game_main(int argc, char **argv, TestBase *t) {
    t->init();

    while (t->running()) {
	t->update();
    }

    return 0;
}
