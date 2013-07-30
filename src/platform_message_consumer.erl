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
  {ok, Connection} = amqp_connection:start(#amqp_params_network{}),

  %% Open a channel on the connection
  {ok, Channel} = amqp_connection:open_channel(Connection),

  amqp_channel:call(Channel, #'queue.declare'{queue = <<"from-platform-queue">>, durable = true}),
  io:format(" [*] Waiting for messages. To exit press CTRL+C~n"),
  
   amqp_channel:subscribe(Channel, #'basic.consume'{queue = <<"from-platform-queue">>, 
                                                    no_ack = true}, self()),
  
  receive
    #'basic.consume_ok'{} -> ok
  end,
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

