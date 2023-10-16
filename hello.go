package main

import (
	"log"
	"net/http"

	_ "time/tzdata"
)

// version is a SemVer string set at build-time (see Dockerfile).
var version string // e.g. 1.2.3

func main() {
	http.HandleFunc("/", helloHandler)

	if err := http.ListenAndServe(":8001", nil); err != nil {
		log.Fatal(err)
	}
}

func helloHandler(r http.ResponseWriter, _ *http.Request) {
	r.Header().Set("Content-Type", "text/plain; charset=UTF-8")
	if _, err := r.Write([]byte("hello world")); err != nil {
		log.Println(err)
	}
}
