LUA = $(HOME)/local/lua/bin/lua
MARKDOWN = Markdown.pl
MD_SRC_DIR = ../embedding-lua-wiki

PAGES = $(basename $(notdir $(wildcard $(MD_SRC_DIR)/*.md)))
HTMLS = $(addprefix html/,$(addsuffix .html,$(PAGES)))
LUAS = $(addprefix lua/,$(addsuffix .lua,$(PAGES)))
MDS = $(addprefix md/,$(addsuffix .md,$(PAGES)))

# test:
# 	echo $(PAGES)
# 	echo $(HTMLS)

all: $(HTMLS)

md/%.md: lua/%.lua
	$(LUA) $< > $@

lua/%.lua: $(MD_SRC_DIR)/%.md
	$(LUA) tang.lua $^ > $@

$(LUAS): lua tang.lua
$(HTMLS): html
$(MDS): eg md

html/%.html: md/%.md
	$(MARKDOWN) $< > $@

lua eg md html:
	mkdir $@

clean:
	rm -rf lua eg md html *~
