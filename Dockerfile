FROM golang:bullseye AS build_base

WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
COPY ./ ./

RUN GOOS=linux go build -ldflags "-w -s" -trimpath -o speedtest .

FROM debian:bullseye

WORKDIR /app
COPY --chown=nobody --from=build_base /build/speedtest ./speedtest
COPY --chown=nobody ./settings.toml ./settings.toml
COPY --chown=nobody ./web/assets ./assets

# Copy self-signed certificates into the image
COPY --chown=nobody ./cert.pem ./cert.pem
COPY --chown=nobody ./privkey.pem ./privkey.pem

USER nobody
EXPOSE 8443

CMD ["./speedtest", "-c", "./settings.toml"]
