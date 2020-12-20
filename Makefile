TMPDIR ?= ../
PONGO_CMD ?= $(TMPDIR)/.kong-pongo/pongo.sh

all: lint test build

.PHONY: lint
lint:
	@echo ">> linting Project"
	@$(PONGO_CMD) lint

.PHONY: build
build:
	@echo ">> building plugin"
	@$(PONGO_CMD) pack

.PHONY: test
test:
	@echo ">> testing plugin"
	@$(PONGO_CMD) run ./spec/

.PHONY: rebuild
rebuild:
	@echo ">> rebuilding pongo"
	@$(PONGO_CMD) build

.PHONY: start
start:
	@echo ">> starting pongo"
	@$(PONGO_CMD) up

.PHONY: stop
stop:
	@echo ">> stopping pongo"
	@$(PONGO_CMD) down

.PHONY: install
install:
ifneq ($(wildcard $(TMPDIR)/.kong-pongo),)
	@echo ">> local tooling already installed"
else
	@echo ">> install local tooling"
	@git clone --single-branch https://github.com/Kong/kong-pongo $(TMPDIR)/.kong-pong
endif
