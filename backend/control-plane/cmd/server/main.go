package main

import (
	"log"

	"github.com/robertodantasdecastro/voitran/backend/control-plane/internal/config"
	"github.com/robertodantasdecastro/voitran/backend/control-plane/internal/httpapi"
)

func main() {
	cfg := config.FromEnv()
	server := httpapi.NewServer(cfg)

	log.Printf("voitran control-plane listening on %s", cfg.Address())
	if err := server.ListenAndServe(); err != nil {
		log.Fatal(err)
	}
}
