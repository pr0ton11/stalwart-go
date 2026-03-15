#!/usr/bin/env python3
"""Patch known issues in the upstream Stalwart OpenAPI spec.

Removes any path entry that is a duplicate with a trailing slash
(e.g. /reload/:) to avoid code generation errors.
"""

import re
import sys
from pathlib import Path

SPEC_FILE = Path("api/openapi.yml")


def patch_spec(spec_file: Path) -> None:
    content = spec_file.read_text()
    content = re.sub(
        r"\n  /reload/:\n    get:.*?(?=\n  /[^ ])",
        "",
        content,
        flags=re.DOTALL,
    )
    spec_file.write_text(content)
    print("Spec patched successfully")


if __name__ == "__main__":
    spec = Path(sys.argv[1]) if len(sys.argv) > 1 else SPEC_FILE
    if not spec.exists():
        print(f"Error: spec file not found: {spec}", file=sys.stderr)
        sys.exit(1)
    patch_spec(spec)
