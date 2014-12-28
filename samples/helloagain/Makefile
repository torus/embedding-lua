LUASRCS = lapi.c lauxlib.c lbaselib.c lbitlib.c lcode.c lcorolib.c      \
          lctype.c ldblib.c ldebug.c ldo.c ldump.c lfunc.c lgc.c        \
          linit.c liolib.c llex.c lmathlib.c lmem.c loadlib.c           \
          lobject.c lopcodes.c loslib.c lparser.c lstate.c lstring.c    \
          lstrlib.c ltable.c ltablib.c ltm.c lundump.c lvm.c lzio.c

LUAOBJS = $(patsubst %.c,lua-5.2.2/src/%.o,$(LUASRCS))
OBJS = $(LUAOBJS) helloagain.o

CFLAGS = -Ilua-5.2.2/src
LFLAGS = -lm

TARGET = helloagain

run: $(TARGET)
	./$^

$(TARGET): $(OBJS)
	$(CC) -o $@ $(LFLAGS) $^

%.o: %.c
	$(CC) -c $(CFLAGS) -o $@ $^

%.o: %.cpp
	$(CXX) -c $(CFLAGS) -o $@ $^

clean:
	rm -f $(OBJS) $(TARGET) *~
