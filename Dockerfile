FROM golang:bullseye AS build_base

WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
COPY ./ ./
RUN GOOS=linux go build -ldflags "-w -s" -trimpath -o speedtest .

FROM debian:bullseye

WORKDIR /app
COPY --from=build_base /build/speedtest /app/speedtest
COPY ./settings.toml /app/settings.toml
COPY ./web/assets /app/assets

USER nobody
EXPOSE 8443

CMD ["./speedtest", "-c", "./settings.toml"]
