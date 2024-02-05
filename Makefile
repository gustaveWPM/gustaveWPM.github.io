.PHONY: all install initialize

MAKEFLAGS += --silent

PM := pnpm

# @Mirror
%:
	$(PM) "$@"

all:
	@echo "Please, provide a command"

# @Mirror
install:
	$(PM) install

initialize: install
