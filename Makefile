LUA = $(HOME)/local/lua/bin/lua
MARKDOWN = Markdown.pl
MD_SRC_DIR = ../embedding-lua-wiki
DOCPUB_DIR = docpub

PAGES = $(basename $(notdir $(wildcard $(MD_SRC_DIR)/*.md)))
HTMLS = $(addprefix html/,$(addsuffix .html,$(PAGES)))
LUAS = $(addprefix lua/,$(addsuffix .lua,$(PAGES)))
MDS = $(addprefix md/,$(addsuffix .md,$(PAGES)))
DOCPUB_MDS = $(addprefix $(DOCPUB_DIR)/md/,$(addsuffix .md,$(PAGES)))

# test:
# 	echo $(PAGES)
# 	echo $(HTMLS)

all: $(HTMLS)

update: $(DOCPUB_MDS) $(DOCPUB_DIR)
	cd $(DOCPUB_DIR) && git commit -m "updated as of `date`" && git push origin master

$(DOCPUB_DIR)/md/%.md: md/%.md
	cp $^ $@ && cd $(DOCPUB_DIR) && git add $^

$(DOCPUB_DIR):
	mkdir $(DOCPUB_DIR)

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
