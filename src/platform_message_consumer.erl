%% Author: rsequeira
%% Created: Jun 24, 2013
%% Description: TODO: Add description
-module(platform_message_consumer).

%%
%% Include files
%%
-include_lib("amqp_client/include/amqp_client.hrl").

%%
%% Exported Functions
%%
-export([start/0]).


%%
%% API Functions
%%
start() ->
  %% Start a network connection
  {ok, Connection} = amqp_connection:start(#amqp_params_network{host="localhost", port=5672}),

  %% Open a channel on the connection
  {ok, Channel} = amqp_connection:open_channel(Connection),

  X = <<"test-exchange">>,
  Q = <<"test-queue">>,
  RoutingKey = <<"test-key">>,

  %% declare a exchange (direct, non-durable)
  ExchangeDeclare = #'exchange.declare'{exchange = X},
  #'exchange.declare_ok'{} = amqp_channel:call(Channel, ExchangeDeclare),

  %% declare a queue
  QueueDeclare = #'queue.declare'{queue = Q, durable = false},
  #'queue.declare_ok'{queue = Q} = amqp_channel:call(Channel, QueueDeclare),

  %% bind the queue to the exchange
  Binding = #'queue.bind'{queue = Q, exchange = X, routing_key = RoutingKey},
  #'queue.bind_ok'{} = amqp_channel:call(Channel, Binding),

  %%amqp_channel:call(Channel, #'queue.declare'{queue = <<"from-platform-queue">>, durable = false}),
  io:format(" [*] Waiting for messages. To exit press CTRL+C~n"),

  amqp_channel:subscribe(Channel, #'basic.consume'{queue = Q,
                                                    no_ack = true}, self()),

  % consume the subscription notification (sent as a message from the gen_server).
  %% The notification contains a tag that identies the subscription which can be used at later
  %% point in time to cancel the subscription
  receive
    #'basic.consume_ok'{consumer_tag = Tag} ->
        io:format("Got subscription notification...~p~n", [Tag]),
        ok
  end,

  %% setup receive loop to consume messages, subscription cancellation, etc.
  loop(Channel).

%%
%% Local Functions
%%
loop(Channel) ->
  receive
    {#'basic.deliver'{}, #amqp_msg{payload = Body}} ->
        io:format(" [x] Received ~p~n", [Body]),
        loop(Channel)
  end.