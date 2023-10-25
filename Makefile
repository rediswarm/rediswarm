build:
	docker buildx bake dev


run:
	docker run --rm -it localhost/redis:dev bash

deploy:
	docker stack deploy -c docker-compose.yml redis

destroy:
	docker stack rm redis
