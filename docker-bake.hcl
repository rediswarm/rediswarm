target "docker-metadata-action" {}

target "default" {
    inherits = ["docker-metadata-action"]
    context = "."
    dockerfile = "Dockerfile"
}

target "dev" {
    inherits = ["default"]
    tags = ["rediswarm/rediswarm:dev"]
    args = {
        S6_VERBOSITY = 2
        S6_BEHAVIOUR_IF_STAGE2_FAILS = 0
    }
}
