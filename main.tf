terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.66.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_codebuild_project" "tf-goreleaser-ecr" {
  name          = "tf-goreleaser-ecr"
  description   = "tf-goreleaser-ecr CI sample"
  service_role  = "arn:aws:iam::776727604074:role/service-role/codebuild"
  build_timeout  = "20"
  queued_timeout = "5"

    artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }


    environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    # compute_type                = "BUILD_ARM1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    # image                       = "docker:dind"
    # image                       = "aws/codebuild/standard:5.0"
    # image                       = "public.ecr.aws/docker/library/golang:latest"
    # image                       = "public.ecr.aws/ubuntu/ubuntu:latest"
    # image                       = "public.ecr.aws/debian/debian:latest"
    # image                         = "public.ecr.aws/amazonlinux/amazonlinux:latest"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true

    environment_variable {
      name  = "GITHUB_TOKEN"
      value = "GITHUB_TOKEN"
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "DOCKER_HUB_ACCESS_TOKEN"
      value = "DOCKER_HUB_ACCESS_TOKEN"
      type  = "PARAMETER_STORE"
    }
  }

 logs_config {
    cloudwatch_logs {
      group_name  = "tf-goreleaser-ecr_build"
    #   stream_name = "log-stream"
    }
  }


  source {
    type            = "GITHUB"
    location        = "https://github.com/prabhatsharma/tf-goreleaser-ecr.git"
    git_clone_depth = 0
  }

#   source_version = "master"
}

resource "aws_codebuild_webhook" "tf-goreleaser-ecr" {
  project_name = "tf-goreleaser-ecr"
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "^refs/tags/.*"
    }
  }

  depends_on = [
    aws_codebuild_project.tf-goreleaser-ecr,
  ]
}

