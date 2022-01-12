package v1

import (
	"encoding/json"
	"net/http"
)

var (
	Version    = "v0.0.0"
	CommitHash = "none"
	BuildDate  = "unknown"
)

func VersionInfo(w http.ResponseWriter, r *http.Request) {

	details := &Details{
		Version:    Version,
		CommitHash: CommitHash,
		BuildDate:  BuildDate,
	}

	bb, _ := json.Marshal(details)
	w.Write(bb)

}

type Details struct {
	Version    string `json:"version"`
	CommitHash string `json:"commit_hash"`
	BuildDate  string `json:"date"`
}
