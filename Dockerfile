# Rust as the base image
FROM rust:1.59 as build

# create a new empty shell project
RUN USER=root cargo new --bin astroport-core
WORKDIR /astroport-core

# copy over your manifests
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

# this build step will cache your dependencies
RUN cargo build --release
RUN rm src/*.rs

# copy your source tree
COPY ./src ./src

# build for release
RUN rm ./target/release/deps/astroport-core*
RUN cargo build --release

# our final base
FROM debian:buster-slim

# copy the build artifact from the build stage
COPY --from=build /astroport-core/target/release/astroport-core .

# set the startup command to run your binary
CMD ["./scripts/build_release.sh"]


# Run each contract
# RUSTFLAGS='-C link-arg=-s' cargo wasm
# cp ../../target/wasm32-unknown-unknown/release/astroport_token.wasm .
# ls -l astroport_token.wasm
# sha256sum astroport_token.wasm