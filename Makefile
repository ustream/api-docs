SHELL:=/bin/bash

.PHONY: help
.DEFAULT_GOAL := help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


init: ## Install dependency packages
	@bundle install

serve: init ## Start the local webserver at http://localhost:4000/
	@bundle exec jekyll serve
