package main

import (
	"fmt"
	"net/http"

	tfgoreleaserecr "github.com/prabhatsharma/tf-goreleaser-ecr"
	v1 "github.com/prabhatsharma/tf-goreleaser-ecr/pkg/meta/v1"
)

func main() {

	fmt.Println("Starting server on port 8080")

	http.HandleFunc("/", v1.VersionInfo)

	// front, err := tfgoreleaserecr.GetFrontendAssets()
	// if err != nil {
	// 	log.Err(err)
	// }

	http.Handle("/ui", http.FileServer(tfgoreleaserecr.GetFileSystem(false)))

	http.ListenAndServe(":8080", nil)

}
