
ROOTDIR := $(shell git rev-parse --show-toplevel)
TEST_CACHE_DIR := $(ROOTDIR)/tests/tflauncher-test-integration/cache
TEST_MODULE_DIR := $(ROOTDIR)/tests/tflauncher-test-integration/module


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

.PHONY: test-chart-pkg-redis
test-chart-pkg-redis:
	cd $(TEST_MODULE_DIR)/redis && tar -zcvf $(TEST_CACHE_DIR)/redis.tgz main.tf;
	cd $(TEST_MODULE_DIR)/redis && zip -r $(TEST_CACHE_DIR)/redis.zip .;

.PHONY: test-chart-pkg-postgres
test-chart-pkg-postgres:
	cd $(TEST_MODULE_DIR)/postgres && tar -zcvf $(TEST_CACHE_DIR)/postgres.tgz main.tf;
	cd $(TEST_MODULE_DIR)/postgres && zip -r $(TEST_CACHE_DIR)/postgres.zip .;

.PHONY: test-chart-pkg-reset
test-chart-pkg-reset:
	rm -rf $(ROOTDIR)/tflauncher-test-integration*.tgz
	rm -rf $(ROOTDIR)/tests/tflauncher-test-integration/cache;
	mkdir -p $(ROOTDIR)/tests/tflauncher-test-integration/cache;

.PHONY: test-chart-pkg
test-chart-pkg: test-chart-pkg-reset test-chart-pkg-redis test-chart-pkg-postgres
	helm package $(ROOTDIR)/tests/tflauncher-test-integration
