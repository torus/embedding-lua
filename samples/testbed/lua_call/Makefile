LUA = $(HOME)/local/lua

CFLAGS = -I$(LUA)/include
LFLAGS = -L$(LUA)/lib

run: lua_call
	./$?

lua_call: lua_call.cpp main.cpp
	$(CXX) -o $@ $(CFLAGS) $(LFLAGS) $^ -llua


clean:
	rm -rf *.o *_wrap.c* *~
