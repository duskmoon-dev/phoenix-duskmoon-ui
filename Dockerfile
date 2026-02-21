FROM ghcr.io/gsmlg-dev/phoenix:alpine AS builder

ARG MIX_ENV=prod
ARG RELEASE_VERSION=1.0.0

COPY . /build
WORKDIR /build

ARG NODE_PATH="/build/apps:/build/deps"

RUN <<EOF
set -ex
apk update
mix deps.get
npm install
export MATCH_STRING="s%@version \"[^\"]\+\"%@version \"${RELEASE_VERSION}\"%"
sed -i "$MATCH_STRING" mix.exs;
sed -i "$MATCH_STRING" apps/duskmoon_storybook_web/mix.exs;
sed -i "$MATCH_STRING" apps/duskmoon_storybook/mix.exs;
sed -i "$MATCH_STRING" apps/phoenix_duskmoon/mix.exs;
cd /build/apps/duskmoon_storybook_web
mix tailwind.install https://github.com/tailwindlabs/tailwindcss/releases/download/v4.0.3/tailwindcss-linux-x64-musl
mix assets.deploy
cd /build
mix release storybook --version "${RELEASE_VERSION}"
cp -r _build/prod/rel/storybook /app
EOF

FROM ghcr.io/gsmlg-dev/alpine:latest

ARG RELEASE_VERSION=1.0.0

LABEL maintainer="GSMLG <gsmlg.com@gmail.com>"
LABEL RELEASE_VERSION="${RELEASE_VERSION}"

LABEL org.opencontainers.image.source="https://github.com/duskmoon-dev/phoenix-duskmoon-ui"
LABEL org.opencontainers.image.description="Duskmoon UI Demo and Storybook"
LABEL org.opencontainers.image.licenses=MIT

ENV PORT=80
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
