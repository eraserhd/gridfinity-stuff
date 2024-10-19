all_TEMPLATES  = $(wildcard *.scad.m4)
all_SCAD_FILES = $(all_TEMPLATES:.m4=)
all_STL_FILES  = $(all_SCAD_FILES:.scad=.stl)

all: $(all_SCAD_FILES) $(all_STL_FILES)
.PHONY: all

%.scad: %.scad.m4
	m4 -P $< > $@

%.stl: %.scad
	openscad -o $@ $<

.DELETE_ON_ERROR: .deps/%.deps
.deps/%.m4.deps: %.m4 deps.m4 Makefile
	mkdir -p "$(dir $@)"
	m4 -P -Dm4_TARGET="$<" deps.m4 $< > $@

-include $(all_TEMPLATES:%=.deps/%.deps)
