LUA = $(HOME)/local/lua/bin/lua

all: nc.so nctest.lua
	$(LUA) nctest.lua

ncurses_wrap.c: ncurses.i
	swig -lua ncurses.i

ncurses_wrap.cpp: ncurses.i
	swig -lua -c++ -o $@ ncurses.i

nc.so: ncurses_wrap.c
	$(CC) -shared -o nc.so -I$(HOME)/local/lua/include/ $^ -L$(HOME)/local/lua/lib -lncurses -llua
