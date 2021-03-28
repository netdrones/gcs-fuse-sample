##
## COLMAP Makefile
## ------
SHELL := /usr/local/bin/bash
DATA ?= ./data
CLUSTER ?= rich-1

## data: download data (make sure you have git lfs on)
.PHONY: data
data:
	git lfs track "*.jpg" "*.jpeg"
	@echo download from https://demuc.de/colmap/datasets/index.html to ./images

# Only use this flag if there are gpu's so on linux
#DOCKER_FLAGS ?= --gpus all
DOCKER_FLAGS ?=



## bash-debug: make sure we have the correct version
bash-debug:
	echo "bash executable is $00"
	bash --version

# https://stackoverflow.com/questions/62309755/how-can-i-mount-the-same-persistent-volume-on-multiple-pods
## pd: Connect to persistent disk
.PHONY: pd
pd:


# https://github.com/colmap/colmap/blob/dev/docker/quick-start.sh
## docker-test-run: Run the same test with docker (deprecated)
.PHONY: docker-test-run
docker-test-run:
	@echo colmap crashes with error code 137 if not enough memory >4GB
	for data in "$(DATA)"/*; do \
		docker run $(DOCKER_FLAGS) --workdir /working \
			-v "$$(readlink -f $$data):/working"  colmap/colmap:latest \
			colmap automatic_reconstructor \
				--workspace_path /working \
				--image_path /working/images \
	; done

## run-test: Run test cases (using docker-compose)
.PHONY: run-test
run-test:
	for data in "$(DATA)"/*; do \
		APP_DATA=$$data docker-compose config && \
		APP_DATA=$$data docker-compose up -d \
	; done

# https://colmap.github.io/cli.html
## test: Run sample data through automatic reconstruction
.PHONY: test
test: clean
	for data in "$(DATA)"/* ; do \
		colmap automatic_reconstructor \
			--workspace_path "$$data" \
			--image_path "$$data/images" \
	; done

## clean: clean the test results
.PHONY: clean
clean:
	rm -rf "$(DATA)"/*/{database.db,sparse}

include ../../lib/include.gcloud.mk
include ../../lib/include.docker.mk
include ../../lib/include.mk
