build:
	docker buildx bake dev --load

run:
	docker run --rm -it rediswarm/rediswarm:dev bash

deploy:
	docker stack deploy -c docker-compose.yml rediswarm-test

destroy:
	docker stack rm rediswarm-test
