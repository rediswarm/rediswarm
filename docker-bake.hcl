target "default" {
    context = "."
    dockerfile = "Dockerfile"
}

target "dev" {
    inherits = ["default"]
    tags = ["localhost/redis:dev"]
}
