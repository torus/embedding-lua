LUA = $(HOME)/local/lua/bin/lua
MARKDOWN = perl md2html.pl
# MARKDOWN = Markdown.pl
MD_SRC_DIR = ../embedding-lua-wiki
DOCPUB_DIR = docpub

MD_SRCS = $(wildcard $(MD_SRC_DIR)/*.md)
PAGES = $(basename $(notdir $(MD_SRCS)))
HTMLS = $(addprefix html/,$(addsuffix .html,$(PAGES)))
LUAS = $(addprefix lua/,$(addsuffix .lua,$(PAGES)))
MDS = $(addprefix md/,$(addsuffix .md,$(PAGES)))
DOCPUB_MDS = $(addprefix $(DOCPUB_DIR)/md/,$(addsuffix .md,$(PAGES)))

WRAPPERS = $(patsubst %.i,%_wrap.cxx,$(wildcard eg/*.i))
WRAPPER_OBJS = $(patsubst %.cxx,%.o,$(WRAPPERS))

# test:
# 	echo $(PAGES)
# 	echo $(HTMLS)

.PHONY: test-swig list-todos

all: $(HTMLS) test-swig list-todos

list-todos:
	@echo Remaning TODOs...
	@grep -i -e '\<\(\(TODO\)\|\(FIXME\)\):' $(MD_SRCS) || echo "ALL DONE!"

test-swig: $(WRAPPER_OBJS)

%_wrap.o: %_wrap.cxx
	g++ -c -I ~/local/lua/include -I ~/src/Box2D_v2.2.1 -o $@ $?

%_wrap.cxx: %.i
	swig -lua -c++ -o $@ $?

update-gh-pages: $(HTMLS)
	cd html && git commit -am "updated as of `date`" && git push origin master:gh-pages

update-docpub: $(DOCPUB_MDS) $(DOCPUB_DIR)
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
