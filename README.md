# A Go Client for the Stalwart Mail Server

This project provides a generated Go client for the [Stalwart Mail Server](https://stalw.art/) API.

## Features

- Generated client based on the [OpenAPI Spec of Stalwart](https://github.com/stalwartlabs/stalwart/blob/main/api/v1/openapi.yml)
- Automated daily sync via GitHub Actions -- a PR is opened automatically when the upstream spec changes
- Uses [oapi-codegen](https://github.com/oapi-codegen/oapi-codegen) for idiomatic Go code generation

## Installation

```bash
go get github.com/pr0ton11/stalwart-go
```

## Usage

```go
package main

import (
	"context"
	"fmt"
	"log"

	"github.com/pr0ton11/stalwart-go/stalwart"
)

func main() {
	// Create a client pointing to your Stalwart server
	client, err := stalwart.NewClientWithResponses("https://mail.example.org/api")
	if err != nil {
		log.Fatal(err)
	}

	// Example: List principals
	resp, err := client.GetPrincipalWithResponse(context.Background(), &stalwart.GetPrincipalParams{})
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("Status: %d\n", resp.StatusCode())
}
```

### Authentication

Most Stalwart API endpoints require authentication. You can provide credentials using a custom `RequestEditorFn`:

```go
import "encoding/base64"

basicAuth := func(ctx context.Context, req *http.Request) error {
	credentials := base64.StdEncoding.EncodeToString([]byte("admin:password"))
	req.Header.Set("Authorization", "Basic "+credentials)
	return nil
}

client, err := stalwart.NewClientWithResponses(
	"https://mail.example.org/api",
	stalwart.WithRequestEditorFn(basicAuth),
)
```

## Development

### Prerequisites

- Go 1.22+
- [oapi-codegen](https://github.com/oapi-codegen/oapi-codegen)

### Regenerating the client

To fetch the latest upstream OpenAPI spec and regenerate the Go client:

```bash
# Install tools (first time only)
make install-tools

# Fetch spec + patch + generate
make generate
```

Or run the full pipeline including tool installation:

```bash
make all
```

### Project structure

```
.
├── .github/workflows/generate.yml  # Automated spec sync & code generation
├── api/openapi.yml                 # Local copy of the Stalwart OpenAPI spec
├── stalwart/client.gen.go          # Generated Go client (types + HTTP client)
├── generate.go                     # go:generate directive
├── tools.go                        # Tool dependency (oapi-codegen)
├── oapi-codegen.yaml               # Code generator configuration
├── Makefile                        # Development commands
└── README.md
```

### How automation works

A GitHub Action runs daily (and can be triggered manually) to:

1. Fetch the latest OpenAPI spec from the [Stalwart repository](https://github.com/stalwartlabs/stalwart)
2. Patch any known upstream spec issues (e.g. duplicate paths)
3. Regenerate the Go client code
4. If changes are detected, open a Pull Request for review

## License

See [LICENSE](LICENSE) for details.
