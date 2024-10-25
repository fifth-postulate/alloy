ARCHIVE=workshop-material.tar.gz
MATERIAL_DIR=build
WEBPAGE_DIR=public-build
SUB_DIRECTORIES=workshop resources
CLEAN_TARGETS=$(addsuffix clean,$(SUB_DIRECTORIES))

.PHONY: all clean ${SUB_DIRECTORIES} ${CLEAN_TARGETS}

all: ${ARCHIVE} ${WEBPAGE_DIR} docs/workshop
${ARCHIVE}: ${MATERIAL_DIR} 
	tar cvfz $@ $<

${MATERIAL_DIR}: ${SUB_DIRECTORIES} ${REFERENCE}
	mkdir -p $@
	cp -rfa resources/material/. $@/
	cp -rfa workshop/guide/book $@/guide
	mkdir -p $@/example
	cp -rfa workshop/example/. $@/example
	cp -rfa presentation $@/presentation

${SUB_DIRECTORIES}:
	${MAKE} -C $@

${WEBPAGE_DIR}: ${MATERIAL_DIR} ${ARCHIVE}
	mkdir -p $@
	echo "<meta http-equiv=refresh content=0;url=guide/index.html>" > $@/index.html
	cp -rfa $</guide $@/guide
	cp -rfa $</presentation $@/presentation
	cp -rfa resources/public/. $@/

docs/workshop: ${WEBPAGE_DIR}
	mkdir -p $@
	cp -rfa $</* $@

clean: ${CLEAN_TARGETS}
	rm -rf ${ARCHIVE} ${MATERIAL_DIR} ${WEBPAGE_DIR} docs/workshop

%clean: %
	${MAKE} -C $< clean
