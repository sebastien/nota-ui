

SOURCES_HTML=$(wildcard src/html/*.html src/html/*/*.html)
SOURCES_XML=$(wildcard src/xml/*.xml src/xml/*/*.xml)
SOURCES_CSS=$(wildcard src/css/*.css src/css/*/*.css)
SOURCES_JS=$(wildcard src/js/*.js src/js/*/*.js src/js/*/*/*.js src/js/*/*/*/*.js)
SOURCES_JSON=$(wildcard src/json/*.json src/json/*/*.json)
SOURCES_PY=$(wildcard src/py/*.py src/py/**/*.py) $(wildcard deps/extra/src/py/**/*.py)

UIJS_JS=$(wildcard deps/uijs/src/js/*.js deps/uijs/src/js/*/*.js deps/uijs/src/js/*/*/*.js)
UIJS_CSS=$(wildcard deps/uijs/src/css/*.css deps/uijs/src/css/*/*.css)
UIJS_XML=$(wildcard deps/uijs/src/xml/*.x?l* deps/uijs/src/xml/*/*.x?l*)


WATCH_PY=$(call rwildcard,src/py,.py) $(foreach D,$(wildcard deps/*/src/py),$(call rwildcard,$D,.py))

BUILD_WHL=$(wildcard build/*.whl)
RUN_HTML=$(SOURCES_HTML:src/html/%=run/lib/html/%)
RUN_XML=$(filter-out run/lib/xml/test-%,$(UIJS_XML:deps/uijs/src/xml/%=run/lib/xml/%)) $(SOURCES_XML:src/xml/%=run/lib/xml/%)
RUN_JS=$(UIJS_JS:deps/uijs/src/js/%=run/lib/js/%) $(SOURCES_JS:src/js/%=run/lib/js/%)
RUN_JSON=$(SOURCES_JSON:src/json/%=run/lib/json/%)
RUN_CSS=$(UIJS_CSS:deps/uijs/src/css/%=run/lib/css/%) $(SOURCES_CSS:src/css/%=run/lib/css/%)
RUN_WHL=$(BUILD_WHL:build/%=run/lib/whl/%)
RUN_PYTHON_MODULE=$(notdir $(firstword $(wildcard src/py/*)))
RUN_ALL=$(RUN_JS) $(RUN_CSS) $(RUN_HTML) $(RUN_XML) $(RUN_JSON) $(RUN_WHL)

cmd-symlink=mkdir -p "$(dir $@)"; ln -sfr "$<" "$@"
rwildcard=$(wildcard $(subst SUF,$2,$(subst PRE,$(if $1,$1,.),PRE/*SUF PRE/*/*SUF PRE/*/*/*SUF PRE/*/*/*/*SUF PRE/*/*/*/*/*SUF PRE/*/*/*/*/*/*/*SUF PRE/*/*/*/*/*/*/*/*SUF PRE/*/*/*/*/*/*/*/*/*SUF PRE/*/*/*/*/*/*/*/*/*/*SUF)))
NULL:=
SPACE:=$(NULL) $(NULL)

PYTHONPATH=$(abspath src/py):$(subst $(SPACE),:,$(foreach P,$(wildcard deps/*/src/py),$(abspath $P)))

.PHONY: run
run: $(RUN_ALL)
	@
	export PYTHONPATH="$(PYTHONPATH)"
	COMMAND="env -C run PORT=8001 PYTHONPATH="$(PYTHONPATH)" python -m $(RUN_PYTHON_MODULE)"
	if [ -z "$$(which entr 2> /dev/null)" ]; then
		echo "--- Running standalone: $$COMMAND"
		env $$COMMAND
	else
		echo "--- Running using entr: $$COMMAND"
		echo Makefile $(WATCH_PY) | xargs -n1 echo | entr -nr $$COMMAND
	fi

.PHONY: clean
clean:
	@for path in run/lib/html run/lib/js/uijs; do
		if [ -e "$$path" ]; then
			unlink "$$path" fi
	done
	if [ -e run ]; then
		find run -type d -empty -delete
	fi

run/lib/whl/%.whl: build/%.whl
	@$(call cmd-symlink)

run/lib/%: src/%
	@$(call cmd-symlink)

run/lib/%: deps/uijs/src/%
	@$(call cmd-symlink)

deps-update:
	@set -euo pipefail
	for DEP in deps/*; do
		echo "STEP Updating dependency: $$DEP"
		git -C $$DEP pull origin main
	done

print-%:
	@$(info $*=$($*))

.ONESHELL:

# EOF
