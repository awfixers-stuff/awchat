# syntax=docker/dockerfile:1

FROM hexpm/elixir:1.18.4-erlang-27.3.4.9-alpine-3.21.7 AS build

RUN apk add --no-cache build-base curl git

WORKDIR /app

# Gleam toolchain
RUN curl -fsSL https://github.com/gleam-lang/gleam/releases/download/v1.16.0/gleam-v1.16.0-linux-amd64.tar.gz \
  | tar -xz -C /usr/local/bin

# Rust toolchain for libsignal NIF
RUN curl -fsSL https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

COPY packages/core packages/core
RUN cd packages/core && gleam build

COPY mix.exs mix.lock ./
COPY config config
COPY apps/gateway/mix.exs apps/gateway/
COPY apps/gateway/lib apps/gateway/lib
COPY apps/gateway/native apps/gateway/native
COPY apps/gateway/priv apps/gateway/priv

ENV MIX_ENV=prod
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get --only prod
RUN mix compile
RUN mix release

FROM alpine:3.23.4 AS runtime

RUN apk add --no-cache libstdc++ openssl ncurses-libs

WORKDIR /app

ENV MIX_ENV=prod
ENV PORT=8080

COPY --from=build /app/_build/prod/rel/relay ./

RUN chmod +x bin/server

EXPOSE 8080

CMD ["bin/server"]