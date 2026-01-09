# Project configuration
PROJECT_NAME := $(shell basename $(CURDIR))
GO := go
GOFLAGS := -v

# Build information
VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
LDFLAGS := -s -w -X main.version=$(VERSION) -X main.commit=$(COMMIT) -X main.date=$(DATE)

# Directories
BIN_DIR := bin

.PHONY: all
all: build

.PHONY: build
build: ## Build the binary
	$(GO) build $(GOFLAGS) -ldflags "$(LDFLAGS)" -o $(BIN_DIR)/$(PROJECT_NAME) ./...

.PHONY: test
test: ## Run tests
	$(GO) test $(GOFLAGS) -race -coverprofile=coverage.out ./...

.PHONY: lint
lint: ## Run linter
	golangci-lint run --config=.golangci.yaml

.PHONY: fmt
fmt: ## Format code
	$(GO) fmt ./...

.PHONY: vet
vet: ## Run go vet
	$(GO) vet ./...

.PHONY: clean
clean: ## Clean build artifacts
	rm -rf $(BIN_DIR)
	rm -f coverage.out

.PHONY: verify
verify: fmt vet lint test ## Run all verification steps

.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
