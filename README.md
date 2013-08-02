rabbitmqtest_erl
================

Erlang app to test RabbitMQ.
Currently, the platform_message_consumer module connects to RabbitMQ and consumes from the "from-platform-queue". 
The associated java application in repo "https://gh.riotgames.com/rsequeira/rabbitmqtest" publishes messages to the "from-platform-exchange" which the above queue binds to.

Building
========

This app uses rebar for dependency management and compilation

### Dependencies

To build the application code, we need the following dependencies which we will build from source:
* amqp_client
* rabbit_common

You will need to download and install the mercurial client from here: http://mercurial.selenic.com

### Building rabbitmqtest_erl

```sh
$ git clone https://gh.riotgames.com/rsequeira/rabbitmqtest_erl.git
$ cd rabbitmqtest_erl
$ make
``` 

Running the above commands will pull down verson 3.1.3 rabbitmq sources (see rebar.config) and build the dependencies (amqp_client, rabbit_common).

Running
=======

Run the consumer as follows:

```sh
$ make run-consumer
```
