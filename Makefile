LUA = $(HOME)/local/lua/bin/lua
MARKDOWN = Markdown.pl
MD_SRC_DIR = ../embedding-lua-wiki

PAGES = $(basename $(notdir $(wildcard $(MD_SRC_DIR)/*.md)))
HTMLS = $(addprefix html/,$(addsuffix .html,$(PAGES)))
LUAS = $(addprefix lua/,$(addsuffix .lua,$(PAGES)))

# test:
# 	echo $(PAGES)
# 	echo $(HTMLS)

all: $(HTMLS)

md/%.md: eg md

md/%.md: lua/%.lua
	$(LUA) $< > $@

lua/%.lua: $(MD_SRC_DIR)/%.md
	$(LUA) tang.lua $^ > $@

$(LUAS): lua tang.lua

html/%.html: html

html/%.html: md/%.md
	$(MARKDOWN) $< > $@

lua eg md html:
	mkdir $@

clean:
	rm -rf lua eg md html *~
