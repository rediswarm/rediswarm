target "docker-metadata-action" {}

target "default" {
    inherits = ["docker-metadata-action"]
    context = "."
    dockerfile = "Dockerfile"
}

target "dev" {
    inherits = ["default"]
    tags = ["rediswarm/rediswarm:dev"]
}
