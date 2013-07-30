REBAR=./rebar

.PHONY: get-deps

all:
	@$(REBAR) get-deps
	@$(REBAR) compile

clean:
	@$(REBAR) clean

get-deps:
	@$(REBAR) get-deps

test:
	@$(REBAR) skip_deps=true eunit
