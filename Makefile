default: up

.PHONY: up
up: kind-up docker-up

.PHONY: kind-up
kind-up:
	kind create cluster --config=./configs/Cluster.yaml

.PHONY: docker-up
docker-up:
	docker compose up -d

.PHONY: down
down: kind-down docker-down

.PHONY: kind-down
kind-down:
	kind delete cluster --name=tflauncher

.PHONY: docker-down
docker-down:
	docker compose down -v