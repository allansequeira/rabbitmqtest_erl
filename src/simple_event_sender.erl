%% Author: rsequeira
%% Created: Aug 10, 2013
%% Description: TODO: Add description

-module(simple_event_sender).

%%
%% Include files
%%
-include_lib("amqp_client/include/amqp_client.hrl").

-define(SERVER, simple_event_sender).

%%
%% Exported functions
%%
-export([start/0, stop/0, get_count/0, loop/5]).

%%
%% API functions
%%
start() ->
  %% Start a network connection
  {ok, Connection} = amqp_connection:start(#amqp_params_network{host="localhost", port=5670}),

  %% Open a channel on the connection
  {ok, Channel} = amqp_connection:open_channel(Connection),

  X = <<"test-exchange">>,
  Q = <<"test-queue">>,
  RoutingKey = <<"test-key">>,

  %% declare a exchange (direct, durable)
  ExchangeDeclare = #'exchange.declare'{exchange = X},
  #'exchange.declare_ok'{} = amqp_channel:call(Channel, ExchangeDeclare),

  %% declare a queue (durable)
  QueueDeclare = #'queue.declare'{queue = Q, durable = false},
  #'queue.declare_ok'{queue = Q} = amqp_channel:call(Channel, QueueDeclare),

  %% bind the queue to the exchange
  Binding = #'queue.bind'{queue = Q, exchange = X, routing_key = RoutingKey},
  #'queue.bind_ok'{} = amqp_channel:call(Channel, Binding),

  %% publish the event to the exchange
  Payload = <<"Event sent from simple_event_sender">>,
  Publish = #'basic.publish'{exchange = X, routing_key = RoutingKey},
  Props = #'P_basic'{delivery_mode = 2},
  Msg = #amqp_msg{props = Props, payload = Payload},
  amqp_channel:cast(Channel, Publish, Msg),

  Pid = spawn(simple_event_sender, loop, [0, Connection, Channel, X, RoutingKey]),
  erlang:register(?SERVER, Pid),

  Pid ! {send_msg, 0, "Event sent from simple event sender"},


  %% close channel, close connection
  %cleanup(Connection, Channel),

  ok.

stop() ->
  ?SERVER ! shutdown.

get_count() ->
  ?SERVER ! {get_count, self()},
  receive
    {ok, Count} ->
      io:format("Got a count of messages: ~p~n", [Count]);
    _ ->
      io:format("What was that again?")
  end,
  ok.
  %%?SERVER ! get_count.

%%
%% Local functions
%%
cleanup(Connection, Channel) ->
  amqp_channel:close(Channel),
  wait_for_death(Channel),
  amqp_connection:close(Connection),
  wait_for_death(Connection).

wait_for_death(Pid) ->
  Ref = erlang:monitor(process, Pid),
  receive { 'DOWN', Ref, process, Pid, _Reason } -> ok
  after 1000 -> exit({timed_out_waiting_for_process_death, Pid})
  end.


loop(Count, Connection, Channel, X, RoutingKey) ->
  receive
    {send_msg, Count, Message} ->
        Event = case Message of
                  [] ->
                    <<"Default event sent from simple_event_sender">>;
                  MsgToSend ->
                    io:format("Msg: ~p~n", [MsgToSend]),
                    list_to_binary(MsgToSend)
                end,
        Publish = #'basic.publish'{exchange = X, routing_key = RoutingKey},
        Props = #'P_basic'{delivery_mode = 2},
        Msg = #amqp_msg{props = Props, payload = Event},
        amqp_channel:cast(Channel, Publish, Msg),

        timer:sleep(1000),
        NewCount = Count + 1,

        self() ! {send_msg, NewCount, "Event sent from simple event sender"},

        loop(NewCount, Connection, Channel, X, RoutingKey);
    {get_count, From} ->
        %%io:format("Count of messages sent: ~p~n", [Count]),
        From ! {ok, Count},
        loop(Count, Connection, Channel, X, RoutingKey);
    shutdown ->
        io:format("Shutting down simple event sender ~n"),
        cleanup(Connection, Channel)
  end.

