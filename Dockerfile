# syntax=docker/dockerfile:1

FROM alpine AS builder

ARG LUA_VERSION=5.1

RUN apk update && apk upgrade
RUN apk add --no-cache \
  ca-certificates curl \
  build-base gcc git make cmake \
	luajit lua-dev lua${LUA_VERSION} \
	luarocks

RUN ln -s /usr/bin/luarocks-${LUA_VERSION} /usr/bin/luarocks
RUN luarocks config lua_dir /usr

FROM builder AS soft
RUN luarocks install --dev t-storage-redis

FROM scratch
COPY --from=soft / /
