
ROOTDIR := $(shell pwd)
TEST_CACHE_DIR := helm_charts/tflauncher-test-integration/cache
TEST_MODULE_DIR := helm_charts/tflauncher-test-integration/module
TEST_MODULES := $(notdir $(wildcard $(TEST_MODULE_DIR)/*))
TEST_MODULES_TGZ := $(foreach module,$(TEST_MODULES),$(TEST_CACHE_DIR)/$(addsuffix .tgz,$(module)))
TEST_MODULES_ZIP := $(foreach module,$(TEST_MODULES),$(TEST_CACHE_DIR)/$(addsuffix .zip,$(module)))

default: up

$(TEST_CACHE_DIR)/%.tgz: $(TEST_MODULE_DIR)/%/main.tf
	mkdir -p $(TEST_CACHE_DIR)
	cd $(dir $<) && tar -zcvf $(ROOTDIR)/$@ *;

$(TEST_CACHE_DIR)/%.zip: $(TEST_MODULE_DIR)/%/main.tf
	mkdir -p $(TEST_CACHE_DIR)
	cd $(dir $<) && zip -r $(ROOTDIR)/$@ *;

cache/tflauncher-test-integration-0.1.0.tgz: ${TEST_MODULES_TGZ} ${TEST_MODULES_ZIP}
	mkdir -p cache
	helm package helm_charts/tflauncher-test-integration -d cache

.PHONY: test-chart-pkg
test-chart-pkg: cache/tflauncher-test-integration-0.1.0.tgz

.PHONY: test-chart-pkg-reset
test-chart-pkg-reset:
	rm -rf cache helm_charts/tflauncher-test-integration/cache;

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
