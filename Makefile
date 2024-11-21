.PHONY: all deploy clean

ARCHIVE=workshop-material.tar.gz
MATERIAL_DIR=build
WEBPAGE_DIR=public-build
WEBPAGE_DEPLOYMENT_DIR=docs/workshop
SUB_DIRECTORIES=docs workshop resources
CLEAN_TARGETS=$(addsuffix clean,$(SUB_DIRECTORIES))

.PHONY: all clean ${SUB_DIRECTORIES} ${CLEAN_TARGETS}

all: ${ARCHIVE} ${WEBPAGE_DIR}
${ARCHIVE}: ${MATERIAL_DIR}
	tar cvfz $@ $<

${MATERIAL_DIR}: ${SUB_DIRECTORIES} ${REFERENCE}
	mkdir -p $@
	cp -Rfa resources/material/. $@/
	cp -Rfa workshop/guide/book $@/guide
	mkdir -p $@/example
	cp -Rfa workshop/example/. $@/example
	cp -Rfa presentation $@/presentation

${SUB_DIRECTORIES}:
	${MAKE} -C $@

${WEBPAGE_DIR}: ${MATERIAL_DIR} ${ARCHIVE}
	mkdir -p $@
	echo "<meta http-equiv=refresh content=0;url=guide/index.html>" > $@/index.html
	cp -Rfa $</guide $@/guide
	cp -Rfa $</presentation $@/presentation
	cp -Rfa resources/public/. $@/

${WEBPAGE_DEPLOYMENT_DIR}: ${WEBPAGE_DIR}
	mkdir -p $@
	cp -Rfa $</* $@

deploy: ${WEBPAGE_DEPLOYMENT_DIR}
	@echo "finished deploying"

clean: ${CLEAN_TARGETS}
	rm -Rf ${ARCHIVE} ${MATERIAL_DIR} ${WEBPAGE_DIR} ${WEBPAGE_DEPLOYMENT_DIR}

%clean: %
	${MAKE} -C $< clean
