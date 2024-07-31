all_TEMPLATES  = $(wildcard *.scad.m4)
all_SCAD_FILES = $(all_TEMPLATES:.m4=)

all: $(all_SCAD_FILES)
.PHONY: all

%.scad: %.scad.m4
	m4 -P $< > $@
