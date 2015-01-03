# SWIG を使って ncurses の Lua バインディングを作り、テストする。

# SWIG がインストールされていることと、
# $(HOME)/local/lua 以下に Lua がインストールされていることを前提としています。

LUADIR = $(HOME)/local/lua
LUA = $(LUADIR)/bin/lua

all: nc.so nctest.lua
	$(LUA) nctest.lua

ncurses_wrap.c: ncurses.i
	swig -lua ncurses.i

ncurses_wrap.cpp: ncurses.i
	swig -lua -c++ -o $@ ncurses.i

nc.so: ncurses_wrap.c
	$(CC) -shared -o $@ -I$(LUADIR)/include/ $^ -L$(LUADIR)/lib -lncurses -llua

clean:
	rm -f nc.so *_wrap.* *~
