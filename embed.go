package tfgoreleaserecr

import (
	"embed"
	"io/fs"
	"log"
	"net/http"
	"os"
)

//go:embed web/dist
var embedFrontend embed.FS

func GetFrontendAssets() (fs.FS, error) {
	f, err := fs.Sub(embedFrontend, "web/dist")
	if err != nil {
		return nil, err
	}

	return f, nil
}

//go:embed web/dist
var embededFiles embed.FS

func GetFileSystem(useOS bool) http.FileSystem {
	if useOS {
		log.Print("using live mode")
		return http.FS(os.DirFS("web/dist"))
	}

	log.Print("using embed mode")
	fsys, err := fs.Sub(embededFiles, "web/dist")
	if err != nil {
		panic(err)
	}

	return http.FS(fsys)
}
