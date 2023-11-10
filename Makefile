PROGRAM := aws-ssm-rename
VERSION ?= v0.0.0 # NB. may not be accurate, overriden in release workflow

ARCHIVE_TARGETS := \
  dist/$(PROGRAM)/aws-ssm-rename \
  dist/$(PROGRAM)/completion/bash \
  dist/$(PROGRAM)/completion/fish \
  dist/$(PROGRAM)/completion/zsh \
  dist/$(PROGRAM)/doc/aws-ssm-rename.1 \
  dist/$(PROGRAM)/Makefile

M4_SETUP_SKIP := $(shell wc -l setup.m4 | awk '{ print $$1 + 1 }')

dist: dist/$(PROGRAM).tar.gz

dist/$(PROGRAM).tar.gz: $(ARCHIVE_TARGETS)
	tar -C ./dist -czvf $@ ./$(PROGRAM)

dist/$(PROGRAM)/%: bin/% setup.m4
	mkdir -p dist/$(PROGRAM)
	cat setup.m4 "$<" | \
	  m4 -D AWS_SSM_RENAME_VERSION=$(VERSION) | \
	  tail -n +$(M4_SETUP_SKIP) >"$@"

dist/$(PROGRAM)/completion/%:
	mkdir -p ./dist/$(PROGRAM)/completion
	echo "# TODO" > $@

dist/$(PROGRAM)/doc/%: man/%.ronn
	mkdir -p ./dist/$(PROGRAM)/doc
	ronn --roff <"$<" >"$@"

dist/$(PROGRAM)/Makefile: Makefile.install
	mkdir -p dist/$(PROGRAM)
	cp "$<" "$@"

.PHONY: clean
clean:
	$(RM) -r ./dist

.PHONY: install.check
install.check: dist/$(PROGRAM).tar.gz
	cp dist/$(PROGRAM).tar.gz /tmp && \
	  cd /tmp && \
	  tar xvf $(PROGRAM).tar.gz && \
	  cd $(PROGRAM) && \
	  make install PREFIX=$$HOME/.local
	PATH=$$HOME/.local/bin:$$PATH aws-ssm-rename --version
