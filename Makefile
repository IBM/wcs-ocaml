all: bin/wcs

bin/wcs: src/wcs_cli
	mkdir -p bin
	cp $< $@

.PHONY: src/wcs_cli clean

src/wcs_cli:
	$(MAKE) -C src

clean:
	$(MAKE) -C src clean

cleanall:
	$(MAKE) -C src cleanall
	rm -f bin/wcs
