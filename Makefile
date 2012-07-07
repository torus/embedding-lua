LUA = $(HOME)/local/lua/bin/lua
MARKDOWN = Markdown.pl

all: md/Language.md html/Language.html

md/Language.md: eg md

md/Language.md: lua/Language.lua
	$(LUA) $< > $@

lua/Language.lua: lua ../embedding-lua-wiki/Language.md tang.lua
	$(LUA) tang.lua ../embedding-lua-wiki/Language.md > $@

html/Language.html: html

html/Language.html: md/Language.md
	$(MARKDOWN) $< > $@

lua eg md html:
	mkdir $@

clean:
	rm -rf lua eg md *~
