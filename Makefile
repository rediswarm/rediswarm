build:
	docker buildx bake dev --load

run:
	docker run --rm -it rediswarm/rediswarm:dev bash

deploy:
	docker stack deploy -c docker-compose.yml rediswarm-test

destroy:
	docker stack rm rediswarm-test

test:
	docker run -it --rm -v $(PWD):/app redis:alpine sh

logs:
	docker service logs -f rediswarm-test_sentinel
