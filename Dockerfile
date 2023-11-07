FROM golang:latest AS build_base

WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download
COPY ./ ./
RUN go build -ldflags "-w -s" -trimpath -o speedtest .

FROM alpine:latest

WORKDIR /app
RUN apk add --no-cache ca-certificates

COPY --from=build_base /build/speedtest ./
COPY settings.toml ./

USER nobody
EXPOSE 8443

CMD ["./speedtest"]
