package domain

type HealthResponse struct {
	Status  string `json:"status"`
	Service string `json:"service"`
	Stage   string `json:"stage"`
}

type CapabilitiesResponse struct {
	Service            string   `json:"service"`
	Stage              string   `json:"stage"`
	SupportedLocales   []string `json:"supported_locales"`
	DualBandEnabled    bool     `json:"dual_band_enabled"`
	VoiceIdentityGuard bool     `json:"voice_identity_guard"`
}

type SessionCreateRequest struct {
	SourceLocale string `json:"source_locale"`
	TargetLocale string `json:"target_locale"`
	Mode         string `json:"mode"`
}

type SessionResponse struct {
	SessionID       string `json:"session_id"`
	Status          string `json:"status"`
	TransportMode   string `json:"transport_mode"`
	SourceLocale    string `json:"source_locale"`
	TargetLocale    string `json:"target_locale"`
	ControlPlaneEnv string `json:"control_plane_env"`
}

type TokenResponse struct {
	SessionID string `json:"session_id"`
	Token     string `json:"token"`
	ExpiresIn int    `json:"expires_in"`
}

type EventRequest struct {
	Type string `json:"type"`
}

type EventResponse struct {
	SessionID string `json:"session_id"`
	Accepted  bool   `json:"accepted"`
	Type      string `json:"type"`
}
