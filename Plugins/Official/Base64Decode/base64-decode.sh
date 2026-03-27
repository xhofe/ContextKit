#!/bin/sh
python3 - "$1" <<'PY'
import base64
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
output = path.with_suffix(path.suffix + ".decoded")
decoded = base64.b64decode(path.read_text().strip())
output.write_bytes(decoded)
print(json.dumps({
    "message": f"Decoded {path.name}",
    "producedPaths": [str(output)],
    "structuredPayload": {"plugin": "base64-decode", "file": str(output)},
    "logLines": [f"Decoded {path} into {output}"]
}))
PY
