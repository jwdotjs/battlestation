.PHONY: server iex mix lint clean test install

server:
	mix phoenix.server

install:
	mix deps.get

iex:
	iex -S mix phoenix.server

mix:
	iex -S mix

lint:
	mix credo --strict

test:
	mix test

clean:
	rm -rf _build

routes:
	mix phoenix.routes
