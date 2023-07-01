FROM rust:1.70.0 AS build
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq update && apt-get -qq install -y libssl-dev libudev-dev libpq-dev pkg-config
RUN cargo install cargo-make@0.35.15 && \
    cargo install sqlx-cli --no-default-features --features native-tls,postgres
WORKDIR /app
COPY . .
RUN find /app -type f -not \( -name \*.toml -or -name \*.sql \) -delete

FROM ubuntu:focal as runtime
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq update && apt-get -qq install -y openssl libudev1 libpq5 ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=build \
    /usr/local/cargo/bin/cargo-make \
    /usr/local/cargo/bin/sqlx \
    /usr/local/rustup/toolchains/1.70.0-x86_64-unknown-linux-gnu/bin/cargo \
    /usr/local/bin/
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["/usr/local/bin/cargo", "make", "setup"]
