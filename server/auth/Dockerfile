# syntax=docker/dockerfile:1

FROM hexpm/elixir:1.18.4-erlang-27.3.4.9-ubuntu-noble-20260509.1 AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential ca-certificates curl git pkg-config \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN curl -fsSL https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

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

FROM debian:bookworm-slim AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    libstdc++6 openssl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV MIX_ENV=prod
ENV PORT=8081

COPY --from=build /app/_build/prod/rel/auth ./

RUN chmod +x bin/server

EXPOSE 8081

CMD ["bin/server"]