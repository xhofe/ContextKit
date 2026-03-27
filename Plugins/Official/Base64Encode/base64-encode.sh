#!/bin/sh
python3 - "$1" <<'PY'
import base64
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
encoded = base64.b64encode(path.read_bytes()).decode("ascii")
print(json.dumps({
    "message": f"Encoded {path.name}",
    "clipboardText": encoded,
    "structuredPayload": {"plugin": "base64-encode", "file": str(path)},
    "logLines": [f"Encoded {path}"]
}))
PY
