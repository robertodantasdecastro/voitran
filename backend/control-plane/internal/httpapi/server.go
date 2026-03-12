package httpapi

import (
	"encoding/json"
	"net/http"
	"strings"
	"time"

	"github.com/robertodantasdecastro/voitran/backend/control-plane/internal/config"
	"github.com/robertodantasdecastro/voitran/backend/control-plane/internal/domain"
)

type Server struct {
	httpServer *http.Server
}

func NewServer(cfg config.Config) *Server {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", healthHandler)
	mux.HandleFunc("GET /v1/capabilities", capabilitiesHandler)
	mux.HandleFunc("POST /v1/sessions", sessionCreateHandler(cfg))
	mux.HandleFunc("POST /v1/sessions/", sessionScopedHandler)

	return &Server{
		httpServer: &http.Server{
			Addr:              cfg.Address(),
			Handler:           mux,
			ReadHeaderTimeout: 5 * time.Second,
		},
	}
}

func (s *Server) ListenAndServe() error {
	return s.httpServer.ListenAndServe()
}

func Handler(cfg config.Config) http.Handler {
	return NewServer(cfg).httpServer.Handler
}

func healthHandler(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, domain.HealthResponse{
		Status:  "ok",
		Service: "voitran-control-plane",
		Stage:   "bootstrap",
	})
}

func capabilitiesHandler(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, domain.CapabilitiesResponse{
		Service:            "voitran-control-plane",
		Stage:              "bootstrap",
		SupportedLocales:   []string{"pt-BR", "en"},
		DualBandEnabled:    true,
		VoiceIdentityGuard: true,
	})
}

func sessionCreateHandler(cfg config.Config) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var request domain.SessionCreateRequest
		_ = json.NewDecoder(r.Body).Decode(&request)

		if request.SourceLocale == "" {
			request.SourceLocale = "pt-BR"
		}
		if request.TargetLocale == "" {
			request.TargetLocale = "en"
		}
		if request.Mode == "" {
			request.Mode = "dual-band"
		}

		writeJSON(w, http.StatusCreated, domain.SessionResponse{
			SessionID:       "stub-session-001",
			Status:          "created",
			TransportMode:   request.Mode,
			SourceLocale:    request.SourceLocale,
			TargetLocale:    request.TargetLocale,
			ControlPlaneEnv: cfg.AppEnv,
		})
	}
}

func sessionScopedHandler(w http.ResponseWriter, r *http.Request) {
	path := strings.TrimPrefix(r.URL.Path, "/v1/sessions/")
	parts := strings.Split(strings.Trim(path, "/"), "/")
	if len(parts) != 2 {
		http.NotFound(w, r)
		return
	}

	sessionID := parts[0]
	resource := parts[1]

	switch resource {
	case "token":
		writeJSON(w, http.StatusOK, domain.TokenResponse{
			SessionID: sessionID,
			Token:     "stub-livekit-token",
			ExpiresIn: 3600,
		})
	case "events":
		var request domain.EventRequest
		_ = json.NewDecoder(r.Body).Decode(&request)
		if request.Type == "" {
			request.Type = "unknown"
		}
		writeJSON(w, http.StatusAccepted, domain.EventResponse{
			SessionID: sessionID,
			Accepted:  true,
			Type:      request.Type,
		})
	default:
		http.NotFound(w, r)
	}
}

func writeJSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}
