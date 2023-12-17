# ____________________________________________________________________________________________________ #
# Functions && Properties start block
# ____________________________________________________________________________________________________ #

PROJECT_PATH=github.com/evgenivanovi
PROJECT_NAME=platform-proto
PROJECT_NAME_GO=$(PROJECT_NAME)-go
PROJECT_NAME_JAVA=$(PROJECT_NAME)-java
PROJECT_NAME_KOTLIN=$(PROJECT_NAME)-kt

PB_GO_MODULE_NAME=$(PROJECT_PATH)/$(PROJECT_NAME_GO)
PB_JAVA_MODULE_NAME=$(PROJECT_PATH)/$(PROJECT_NAME_JAVA)
PB_KOTLIN_MODULE_NAME=$(PROJECT_PATH)/$(PROJECT_NAME_KOTLIN)

PB_SRC_PATH=$(CURDIR)/vendorpb/proto
PB_GEN_PATH=$(CURDIR)

PB_GO_GEN_PATH=$(PB_GEN_PATH)

# __________________________________________________ #
# GO Properties
# __________________________________________________ #

GOBIN?=$(GOPATH)/bin
LOCAL_BIN:=$(CURDIR)/bin
export PATH:=$(PATH):$(GOBIN)

# ____________________________________________________________________________________________________ #
# Functions && Properties end block
# ____________________________________________________________________________________________________ #

# ____________________________________________________________________________________________________ #
# Scripts start block
# ____________________________________________________________________________________________________ #

.PHONY: init
init:
	@echo 'Project initialization.'

	@echo 'Installing dependencies.'

	@mkdir -p $(LOCAL_BIN)

	@ls $(LOCAL_BIN)/protoc-gen-go &> /dev/null || \
		GOBIN=$(LOCAL_BIN) go install google.golang.org/protobuf/cmd/protoc-gen-go@latest

	@ls $(LOCAL_BIN)/protoc-gen-go-grpc &> /dev/null || \
		GOBIN=$(LOCAL_BIN) go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

	@ls $(LOCAL_BIN)/protodep &> /dev/null || \
		GOBIN=$(LOCAL_BIN) go install github.com/stormcat24/protodep@latest

	@ls $(LOCAL_BIN)/buf &> /dev/null || \
    		GOBIN=$(LOCAL_BIN) go install github.com/bufbuild/buf/cmd/buf@latest

# __________________________________________________ #

.PHONY: go/tidy
go/tidy:
	@find $(CURDIR) \
		-name 'go.mod' \
		-exec bash -c 'pushd "$${1%go.mod}" && go mod tidy && popd' _ {} \; \
		> /dev/null

# __________________________________________________ #

.PHONY: proto/go/deps
proto/go/deps:
	@echo 'Installing dependencies.'

	@mkdir -p $(LOCAL_BIN)

	@ls $(LOCAL_BIN)/protoc-gen-go &> /dev/null || \
		GOBIN=$(LOCAL_BIN) go install google.golang.org/protobuf/cmd/protoc-gen-go@latest

	@ls $(LOCAL_BIN)/protoc-gen-go-grpc &> /dev/null || \
		GOBIN=$(LOCAL_BIN) go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

	@ls $(LOCAL_BIN)/protodep &> /dev/null || \
    	  GOBIN=$(LOCAL_BIN) go install github.com/stormcat24/protodep@latest

# __________________________________________________ #

.PHONY: proto/go/init
proto/go/init: proto/go/deps
	@echo 'Downloading proto files.'
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) \
	protodep up -f

# __________________________________________________ #

.PHONY: proto/go/clean
proto/go/clean: init
	@echo 'Cleaning generated proto files.'
	@$(shell find $(PB_GO_GEN_PATH) -name '*.pb.go' -exec rm -rf {} \;)

# __________________________________________________ #

.PHONY: proto/go/compile
proto/go/compile: init proto/go/init
	@echo 'Installing dependencies for module'
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) \
	pushd $(PB_GO_GEN_PATH) > /dev/null && \
		go get google.golang.org/protobuf@latest && \
		go get google.golang.org/grpc@latest && \
		popd > /dev/null

	@echo 'Compiling proto files.'
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) \
	protoc \
        --proto_path $(PB_SRC_PATH) \
        --go_out=$(PB_GO_GEN_PATH) \
        --go_opt=paths=source_relative \
        --go-grpc_out=$(PB_GO_GEN_PATH) \
        --go-grpc_opt=paths=source_relative \
        $(shell find $(PB_SRC_PATH) -name '*.proto')

	@echo 'Finalizing'
	@pushd $(PB_GO_GEN_PATH) > /dev/null && go mod tidy || true && popd > /dev/null

# ____________________________________________________________________________________________________ #
# Scripts end block
# ____________________________________________________________________________________________________ #
