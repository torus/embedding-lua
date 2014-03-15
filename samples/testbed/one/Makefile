LUA = $(HOME)/local/lua/bin/lua
TESTBED = ../testbed
ENGINE_OBJS = ncurses_wrap.o game_engine.o
OBJECTS = $(patsubst %.o,$(TESTBED)/%.o,$(ENGINE_OBJS)) main.o
TARGET = one
CFLAGS = -I$(HOME)/local/lua/include -I$(TESTBED)
LFLAGS = -L$(HOME)/local/lua/lib -lncurses -llua

all: $(TARGET)
	./$(TARGET)

$(TESTBED)/ncurses_wrap.cpp:
	$(MAKE) -C $(TESTBED) ncurses_wrap.cpp

$(TARGET): $(OBJECTS)
	$(CXX) -o $@ $^ $(LFLAGS)

%.o: %.cpp
	$(CXX) -c -o $@ $(CFLAGS) $^

clean:
	rm -f *.o *~ $(TARGET)
