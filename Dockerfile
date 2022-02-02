# syntax=docker/dockerfile:experimental

############################
# STEP 1 build executable binary
############################
# FROM golang:alpine AS builder
FROM --platform=$BUILDPLATFORM public.ecr.aws/docker/library/golang:latest as builder
ARG VERSION
ARG COMMIT_HASH
ARG BUILD_DATE
ARG TARGETOS
ARG TARGETARCH

RUN update-ca-certificates
# RUN apk update && apk add --no-cache git
# Create appuser.
ENV USER=appuser
ENV UID=10001 
# See https://stackoverflow.com/a/55757473/12429735RUN 
RUN adduser \    
    --disabled-password \    
    --gecos "" \    
    --home "/nonexistent" \    
    --shell "/sbin/nologin" \    
    --no-create-home \    
    --uid "${UID}" \    
    "${USER}"
WORKDIR $GOPATH/src/github.com/prabhatsharma/tf-goreleaser-ecr/
COPY . .
# Fetch dependencies.
# Using go get.
RUN go get -d -v

RUN LDFLAGS="-s -w -X github.com/prabhatsharma/tf-goreleaser-ecr/pkg/meta/v1.Version=${VERSION} -X github.com/prabhatsharma/tf-goreleaser-ecr/pkg/meta/v1.CommitHash=${COMMIT_HASH} -X github.com/prabhatsharma/tf-goreleaser-ecr/pkg/meta/v1.BuildDate=${BUILD_DATE}"
RUN echo "$LDFLAGS" >> /variables.txt
RUN echo "$VERSION" >> /variables.txt
RUN echo "$COMMIT_HASH" >> /variables.txt
RUN echo "$BUILD_DATE" >> /variables.txt

RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -ldflags=$LDFLAGS -o tf-goreleaser-ecr cmd/tf-goreleaser-ecr/main.go
############################
# STEP 2 build a small image
############################
# FROM public.ecr.aws/lts/ubuntu:latest
FROM scratch
COPY --from=builder /variables.txt /variables.txt
# Import the user and group files from the builder.
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Copy the ssl certificates
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# Copy our static executable.
COPY --from=builder  /go/src/github.com/prabhatsharma/tf-goreleaser-ecr/tf-goreleaser-ecr /go/bin/tf-goreleaser-ecr

# Use an unprivileged user.
USER appuser:appuser
# Port on which the service will be exposed.
EXPOSE 8080
# Run the tf-goreleaser-ecr binary.
ENTRYPOINT ["/go/bin/tf-goreleaser-ecr"]
