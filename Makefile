LUA = $(HOME)/local/lua/bin/lua

test: dest/Language.lua
	$(LUA) $^

dest/Language.lua: dest ../embedding-lua-wiki/Language.md tang.lua
	$(LUA) tang.lua ../embedding-lua-wiki/Language.md > $@

dest:
	mkdir $@
