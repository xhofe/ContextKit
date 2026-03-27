#!/bin/sh
python3 - "$1" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
formatted = json.dumps(json.loads(path.read_text()), indent=2, ensure_ascii=False)
print(json.dumps({
    "message": f"Formatted {path.name}",
    "clipboardText": formatted,
    "structuredPayload": {"plugin": "json-format", "file": str(path)},
    "logLines": [f"Formatted {path}"]
}))
PY
