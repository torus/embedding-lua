LUASRCS = lapi.c lauxlib.c lbaselib.c lbitlib.c lcode.c lcorolib.c      \
          lctype.c ldblib.c ldebug.c ldo.c ldump.c lfunc.c lgc.c        \
          linit.c liolib.c llex.c lmathlib.c lmem.c loadlib.c           \
          lobject.c lopcodes.c loslib.c lparser.c lstate.c lstring.c    \
          lstrlib.c ltable.c ltablib.c ltm.c lundump.c lvm.c lzio.c
LUADIR = ../../lua-5.2.3
LUAOBJS = $(patsubst %.c,$(LUADIR)/src/%.o,$(LUASRCS))

ENGINEOBJS_BASE = ncurses_wrap.o game_engine.o
ENGINEOBJS = $(patsubst %.o,$(TESTBED)/%.o,$(ENGINEOBJS_BASE)) main.o

OBJS = $(LUAOBJS) $(ENGINEOBJS)

CFLAGS = -I$(LUADIR)/src -I$(TESTBED)
LFLAGS = -lm -lboost_timer -lboost_system -lncurses

run: $(TARGET)
	./$^

$(TARGET): $(OBJS)
	$(CXX) -o $@ $(LFLAGS) $^

%.o: %.c
	$(CC) -c $(CFLAGS) -o $@ $^

%.o: %.cpp
	$(CXX) -c $(CFLAGS) -o $@ $^

clean:
	rm -f $(OBJS) $(TARGET) *~
