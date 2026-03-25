package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
)

func isPrime(value int) bool {
	for i := 2; i <= value/2; i++ {
		if value%i == 0 {
			return false
		}
	}
	return value > 1
}

func main() {
	m := gin.Default()
	m.LoadHTMLGlob("templates/*")

	m.GET("/", func(c *gin.Context) {
		waitQuery := c.Request.URL.Query().Get("wait")
		primeQuery := c.Request.URL.Query().Get("prime")

		if waitQuery != "" {
			sleep, _ := strconv.Atoi(waitQuery)
			log.Printf("Sleep for %d seconds\n", sleep)
			time.Sleep(time.Duration(sleep) * time.Second)
		}
		if primeQuery != "" {
			val, _ := strconv.Atoi(primeQuery)
			log.Printf("Is %d prime: %t", val, isPrime(val))
		}
		c.HTML(http.StatusOK, "index.tmpl", nil)
	})

	if os.Getenv("PANIC") == "true" {
		panic("this is crashing")
	}

	port := "3000"
	if os.Getenv("PORT") != "" {
		port = os.Getenv("PORT")
	}

	server := &http.Server{Handler: m}

	listeners := make([]net.Listener, 0, 2)

	primaryListener, err := net.Listen("tcp", ":"+port)
	if err != nil {
		panic(err)
	}
	listeners = append(listeners, primaryListener)

	if port != "80" {
		listener80, err := net.Listen("tcp", ":80")
		if err != nil {
			log.Printf("Could not listen on port 80: %v", err)
		} else {
			listeners = append(listeners, listener80)
		}
	}

	for _, l := range listeners {
		go func(l net.Listener) {
			if err := server.Serve(l); err != nil && err != http.ErrServerClosed {
				log.Printf("HTTP server error on %s: %v", l.Addr().String(), err)
			}
		}(l)
		log.Printf("Listening on %s", l.Addr().String())
	}

	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGTERM, syscall.SIGINT)
	<-sigs
	fmt.Println("Signal received, time to shutdown")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := server.Shutdown(ctx); err != nil {
		log.Printf("Shutdown error: %v", err)
	}
}
