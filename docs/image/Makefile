.PHONY: all clean

DOTS=$(wildcard *.dot)
SVGS=$(wildcard *.svg)
DOT_PNGS=$(addsuffix .png,${DOTS})
SVG_PNGS=$(addsuffix .png,${SVGS})

all: ${SVG_PNGS} ${DOT_PNGS}
	@echo "Finished creating pngs"

%.svg.png: %.svg
	inkscape -w 200 -D -f $< -e $@

%.dot.png: %.dot
	dot -Tpng -O $<

clean:
	rm -rf ${DOT_PNGS} ${SVG_PNGS}
