.PHONY: all deploy clean

ARCHIVE=workshop-material.tar.gz
MATERIAL_DIR=build/material
WEBPAGE_DIR=build/public
GUIDE_BUILD_DIR=build/guide
WEBPAGE_DEPLOYMENT_DIR=docs/workshop
SUB_DIRECTORIES=docs workshop resources
CLEAN_TARGETS=$(addsuffix clean,$(SUB_DIRECTORIES))

.PHONY: all clean ${SUB_DIRECTORIES} ${CLEAN_TARGETS}

all: ${ARCHIVE} ${WEBPAGE_DIR}
${ARCHIVE}: ${MATERIAL_DIR}
	tar cvfz $@ $<

${MATERIAL_DIR}: ${SUB_DIRECTORIES} ${REFERENCE} workshop/guide/highlight-alloy.js
	mkdir -p $@
	cp -Rfa resources/material/. $@/
	cp -Rfa ${GUIDE_BUILD_DIR}/ $@/guide/
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

workshop/guide/highlight-alloy.js: highlight-alloy/highlight-alloy.ts highlight-alloy/package-lock.json highlight-alloy/tsconfig.json
	cd highlight-alloy && npm run build
	cp highlight-alloy/highlight-alloy.js $@

deploy: ${WEBPAGE_DEPLOYMENT_DIR}
	@echo "finished deploying"

clean: ${CLEAN_TARGETS}
	rm -Rf ${ARCHIVE} ${MATERIAL_DIR} ${WEBPAGE_DIR} ${WEBPAGE_DEPLOYMENT_DIR}

%clean: %
	${MAKE} -C $< clean
