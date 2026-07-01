ARG BUN_VERSION=1.3.13

FROM oven/bun:${BUN_VERSION} AS bun

FROM rust:1-trixie AS rust

FROM elixir:1.19-otp-28 AS builder

ARG MIX_ENV=prod
ARG RELEASE_VERSION=1.0.0

ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV DUSKMOON_BUILD_NATIVE_FROM_SOURCE=1
ENV QUICKBEAM_BUILD=1
ENV PATH="/usr/local/cargo/bin:${PATH}"

COPY --from=bun /usr/local/bin/bun /usr/local/bin/bun
COPY --from=rust /usr/local/cargo /usr/local/cargo
COPY --from=rust /usr/local/rustup /usr/local/rustup
COPY . /build
WORKDIR /build

RUN <<EOF
set -ex
apt-get update
apt-get install -y --no-install-recommends bash build-essential curl git nodejs npm pkg-config unzip xz-utils
rm -rf /var/lib/apt/lists/*
mix local.hex --force
mix local.rebar --force
mix deps.get
mix zig.get --version 0.15.2
npm install --ignore-scripts --no-audit --no-fund --package-lock=false --registry=https://registry.npmjs.org/
export MATCH_STRING="s%@version \"[^\"]\+\"%@version \"${RELEASE_VERSION}\"%"
sed -i "$MATCH_STRING" mix.exs;
sed -i "$MATCH_STRING" apps/duskmoon_storybook/mix.exs;
sed -i "$MATCH_STRING" apps/phoenix_duskmoon/mix.exs;
mix duskmoon_bundler.build duskmoon_storybook
mix phx.digest
mix release storybook --version "${RELEASE_VERSION}"
cp -r _build/prod/rel/storybook /app
EOF

FROM debian:trixie-slim

ARG RELEASE_VERSION=1.0.0

LABEL maintainer="GSMLG <gsmlg.com@gmail.com>"
LABEL RELEASE_VERSION="${RELEASE_VERSION}"

LABEL org.opencontainers.image.source="https://github.com/duskmoon-dev/phoenix-duskmoon-ui"
LABEL org.opencontainers.image.description="Duskmoon UI Demo and Storybook"
LABEL org.opencontainers.image.licenses=MIT

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates openssl libncurses6 libstdc++6 && \
    rm -rf /var/lib/apt/lists/*

ENV PORT=80
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV REPLACE_OS_VARS=true
ENV ERL_EPMD_PORT=4369
ENV ERLCOOKIE=duskmoon_storybook
ENV HOST=duskmoon-storybook.gsmlg.dev
ENV POOL_SIZE=10
ENV PHX_SERVER=true

COPY --from=builder /app /app

EXPOSE 80

ENV PATH="/app/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

CMD ["/app/bin/storybook", "start"]
