package config

import "os"

type Config struct {
	Host   string
	Port   string
	AppEnv string
}

func FromEnv() Config {
	return Config{
		Host:   valueOrDefault("HOST", "0.0.0.0"),
		Port:   valueOrDefault("PORT", "8080"),
		AppEnv: valueOrDefault("APP_ENV", "development"),
	}
}

func (c Config) Address() string {
	return c.Host + ":" + c.Port
}

func valueOrDefault(key string, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}
