FROM rust:1.70.0 AS chef
RUN cargo install cargo-chef@0.1.54
WORKDIR /app

FROM chef AS plan
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef as build
ARG DEBIAN_FRONTEND=noninteractive
ARG CARGO_NET_GIT_FETCH_WITH_CLI=true
RUN mkdir -m 0700 -p ~/.ssh && ssh-keyscan -H github.com > ~/.ssh/known_hosts
RUN apt-get -qq update && apt-get -qq install -y openssl libudev-dev libpq-dev
COPY --from=plan /app/recipe.json recipe.json
COPY docker-build-config /root/
RUN --mount=type=ssh cargo chef cook --release --recipe-path recipe.json
COPY . .
RUN cargo build --offline --release --bin {{ project-name }}-service

FROM ubuntu:focal as runtime
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq update && apt-get -qq install -y openssl ca-certificates libpq5 && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/target/release/{{ project-name }}-service /usr/local/bin
ENTRYPOINT ["/usr/local/bin/{{ project-name }}-service"]
