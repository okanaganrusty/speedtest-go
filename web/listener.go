//go:build !linux
// +build !linux

package web

import (
	"crypto/tls"
	"github.com/go-chi/chi/v5"
	"github.com/librespeed/speedtest/config"
	log "github.com/sirupsen/logrus"
	"net"
	"net/http"
)

func startListener(conf *config.Config, r *chi.Mux) error {
	var s error

	addr := net.JoinHostPort(conf.BindAddress, conf.Port)
	log.Infof("Starting backend server on %s", addr)

	// TLS, HTTP/2 and HTTP/3
	if conf.EnableTLS {
		log.Info("Enabling TLS connections (listener.go)")

		if conf.EnableHTTP2 {
			log.Info("Using HTTP/2 support")

			srv := &http.Server{
				Addr:         addr,
				Handler:      r,
				TLSNextProto: make(map[string]func(*http.Server, *tls.Conn, http.Handler)),
			}
			s = srv.ListenAndServeTLS(conf.TLSCertFile, conf.TLSKeyFile)
		} else {
			s = http.ListenAndServeTLS(addr, conf.TLSCertFile, conf.TLSKeyFile, r)
		}

		if conf.EnableHTTP3 {
			log.Info("Using HTTP/3 support")

			s = http3.ListenAndServe(addr, conf.TLSCertFile, conf.TLSKeyFile, r)
		}
	} else {
		if conf.EnableHTTP2 {
			log.Errorf("TLS is mandatory for HTTP/2. Ignore settings that enable HTTP/2.")
		}

		s = http.ListenAndServe(addr, r)
	}

	return s
}
