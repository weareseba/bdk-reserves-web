FROM rust:1.72-alpine3.18 as builder
RUN apk add --no-cache build-base
RUN adduser -S -G abuild satoshi
USER satoshi
WORKDIR /home/satoshi
COPY . .
RUN cargo test
RUN cargo build --release
RUN install -D target/release/bdk-reserves-web dist/bin/bdk-reserves-web
RUN ldd target/release/bdk-reserves-web | tr -s [:blank:] '\n' | grep ^/ | xargs -I % install -D % dist/%
RUN ln -s ld-musl-x86_64.so.1 dist/lib/libc.musl-x86_64.so.1

FROM scratch
COPY --from=builder /home/satoshi/dist /
USER 65534
ENTRYPOINT ["/bin/bdk-reserves-web"]