# syntax=docker/dockerfile:1

FROM hexpm/elixir:1.18.4-erlang-27.3.4.9-ubuntu-noble-20260509.1 AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential ca-certificates git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY mix.exs mix.lock ./
COPY config config
COPY lib lib

ENV MIX_ENV=prod
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get --only prod
RUN mix compile
RUN mix release

FROM ubuntu:noble AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    libstdc++6 openssl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV MIX_ENV=prod
ENV PORT=8080
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

COPY --from=build /app/_build/prod/rel/broker ./

EXPOSE 8080

CMD ["./bin/broker", "start"]