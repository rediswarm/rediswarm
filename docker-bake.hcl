target "docker-metadata-action" {}

target "base" {
    inherits = ["docker-metadata-action"]
    context = "."
    dockerfile = "Dockerfile"
}

target "default" {
    inherits = ["docker-metadata-action", "base"]
    platforms = ["linux/amd64", "linux/arm64"]
}

target "dev" {
    inherits = ["base"]
    tags = ["rediswarm/rediswarm:dev"]
    args = {
        S6_VERBOSITY = 2
        S6_BEHAVIOUR_IF_STAGE2_FAILS = 0
    }
}
