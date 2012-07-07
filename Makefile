LUA = $(HOME)/local/lua/bin/lua

md/Language.md: lua/Language.lua
	$(LUA) $^ > $@

lua/Language.lua: lua eg md ../embedding-lua-wiki/Language.md tang.lua
	$(LUA) tang.lua ../embedding-lua-wiki/Language.md > $@

lua:
	mkdir $@

eg:
	mkdir $@

md:
	mkdir $@

clean:
	rm -rf lua eg md *~
