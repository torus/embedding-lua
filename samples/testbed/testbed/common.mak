LUA_DIR = $(HOME)/local/lua

ENGINE_OBJS = ncurses_wrap.o game_engine.o
OBJECTS = $(patsubst %.o,$(TESTBED)/%.o,$(ENGINE_OBJS)) main.o
CFLAGS = -I$(LUA_DIR)/include -I$(TESTBED)
LFLAGS = -L$(LUA_DIR)/lib -lboost_timer -lboost_system -lncurses -llua

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
