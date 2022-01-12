# CI sample with goreleaser


Uses following:

1. Go
1. goreleaser (for heavylifting of building)
1. Docker & ECR
1. Github for source code and publishing releases
1. Terraform for building aws codebuild project
1. parameter store for storing guthub token
1. Buildx (through goreleaser) for creating multiarch containers

