# Created By Luis Fuentes

SHELL = /bin/bash

.DEFAULT_GOAL := help

IMAGE_NAME=snowparkenvironment

.PHONY: build
build: ## (Local): Build Docker image
	@ echo "********** Building image **********"
	@ docker image build --rm -t ${IMAGE_NAME} .
	@ echo "********** Cleanup **********"
	@ docker image prune -f

help:
	@ echo "Please use \`make <target>' where <target> is one of"
	@ perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-25s\033[0m %s\n", $$1, $$2}'