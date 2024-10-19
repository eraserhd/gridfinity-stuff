all_TEMPLATES  = $(wildcard *.scad.m4)
all_SCAD_FILES = $(all_TEMPLATES:.m4=)

all: $(all_SCAD_FILES)
.PHONY: all

%.scad: %.scad.m4
	m4 -P $< > $@

.DELETE_ON_ERROR: .deps/%.deps
.deps/%.m4.deps: %.m4 Makefile
	mkdir -p "$(dir $@)"
	sed -n -e 's/)m4_dnl//' -e 's/m4_include(/$(<:%.m4=%): /p' $< > $@

-include $(all_TEMPLATES:%=.deps/%.deps)
