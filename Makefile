REBAR=./rebar

.PHONY: get-deps

all:
	@$(REBAR) get-deps
	@make -C deps/rabbitmq-erlang-client

	@rm -rf deps/rabbit_common
	@echo "Copying rabbit_common to deps/."
	@cp -R deps/rabbitmq-erlang-client/dist/rabbit_common-0.0.0 deps/.
	@echo "Renaming rabbit_common..."
	@mv deps/rabbit_common-0.0.0 deps/rabbit_common

	@rm -rf deps/amqp_client
	@echo "Copying amqp_client to deps/."
	@cp -R deps/rabbitmq-erlang-client/dist/amqp_client-0.0.0 deps/.
	@echo "Renaming amqp_client..."
	@mv deps/amqp_client-0.0.0 deps/amqp_client

	
	@$(REBAR) compile


clean:
	@$(REBAR) clean

get-deps:
	@$(REBAR) get-deps

test:
	@$(REBAR) skip_deps=true eunit
