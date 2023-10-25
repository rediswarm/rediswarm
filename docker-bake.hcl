target "default" {
    context = "."
    dockerfile = "Dockerfile"
}

target "dev" {
    inherits = ["default"]
    tags = ["rediswarm/rediswarm:dev"]
}
