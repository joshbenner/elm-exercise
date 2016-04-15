.PHONY: all clean dev

APP = App.elm
APP_JS = app.js
ELM_FILES = $(shell find . -type f -name '*.elm')

all: $(APP_JS)

$(APP_JS): $(ELM_FILES)
	elm-make --yes $(APP) --output $@

clean-deps:
	rm -rf elm-stuff

clean:
	rm -f $(APP_JS)
	rm -rf elm-stuff/build-artifacts

dev: all
	elm-reactor
