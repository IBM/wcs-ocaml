all: bin/wcs-cli

bin/wcs-cli: src/wcs_cli
	mkdir -p bin
	cp $< $@

.PHONY: src/wcs_wcs clean

src/wcs_cli:
	$(MAKE) -C src

clean:
	$(MAKE) -C src clean

cleanall:
	$(MAKE) -C src cleanall
	rm -f bin/wcs-cli
