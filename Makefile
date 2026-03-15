.PHONY: generate install-tools patch-spec fetch-spec clean all

OPENAPI_SPEC_URL := https://raw.githubusercontent.com/stalwartlabs/stalwart/main/api/v1/openapi.yml
SPEC_FILE := api/openapi.yml

# Install required tools
install-tools:
	go install github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen@latest

# Fetch the latest OpenAPI spec from upstream
fetch-spec:
	curl -sL "$(OPENAPI_SPEC_URL)" -o $(SPEC_FILE)

# Patch known issues in the upstream spec (e.g. duplicate /reload/ path)
# Removes any path entry that is a duplicate with a trailing slash (e.g. /reload/:)
patch-spec:
	@python3 patch_spec.py $(SPEC_FILE)

# Generate Go client from OpenAPI spec
generate: fetch-spec patch-spec
	go generate ./...
	go mod tidy

# Remove generated files
clean:
	rm -f stalwart/client.gen.go

# Full pipeline: install tools, fetch spec, generate
all: install-tools generate
