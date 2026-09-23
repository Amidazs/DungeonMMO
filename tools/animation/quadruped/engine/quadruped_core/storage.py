"""Atomic JSON persistence; explicit replacement of existing files."""
import json, os, tempfile
from pathlib import Path
from .schema import validate
def load(path,expected_kind):
    try:
        data=json.loads(Path(path).read_text(encoding="utf-8-sig"))
        return validate(data,expected_kind)
    except (json.JSONDecodeError,KeyError,TypeError) as exc:raise ValueError("invalid document: "+str(exc)) from exc
def save(path,data,overwrite=False):
    validate(data,data.get("kind"))
    path=Path(path);path.parent.mkdir(parents=True,exist_ok=True)
    encoded=json.dumps(data,indent=2,allow_nan=False)+"\n"
    if not overwrite:
        with path.open("x",encoding="utf-8") as stream:stream.write(encoded)
        return
    name=None
    try:
        with tempfile.NamedTemporaryFile("w",encoding="utf-8",dir=path.parent,delete=False) as stream:
            name=stream.name;stream.write(encoded);stream.flush();os.fsync(stream.fileno())
        os.replace(name,path);name=None
    finally:
        if name and os.path.exists(name):os.unlink(name)
