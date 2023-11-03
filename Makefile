KEY ?= privkey.pem
CERT ?= cert.pem

CN ?= speedtest.localhost.localdomain
EMAIL ?= admin@speedtest.localhost.localdomain
COUNTRY ?= "CA"
STATE ?= "BC"
LOCATION ?= "Vancouver"
O ?= "localhost"
OU ?= "localhost"

SUBJECT ?= "/CN=$(CN)/emailAddress=$(EMAIL)/C=$(COUNTRY)/ST=$(STATE)/L=$(LOCATION)/O=$(O)/OU=$(OU)/"

certs:
	openssl req -x509 -newkey rsa:2048 -keyout $(KEY) -out $(CERT) -days 365 -nodes -subj $(SUBJECT)

build:
	go build

run:
	speedtest

all: certs build run
