"""Package an already verified build without local credentials or business data."""

from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
import tarfile
import zipfile
from datetime import datetime, timedelta, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SOURCE = Path(__file__).resolve().parent
SHA = lambda data: hashlib.sha256(data).hexdigest()
FILES = (
    ".env.example", ".dockerignore", "Dockerfile", "compose.yaml",
    "nginx/innocence-local.conf", "prepare.sh", "start.sh", "README.zh-CN.md",
    "nginx/innocence-acme.conf.template", "nginx/innocence-api-https.conf.template",
    "prepare-ip-certificate.sh", "enable-public-api.sh", "backup-before-upgrade.sh",
    "verify-backup-restore.sh", "upgrade-online-backend.sh",
    "systemd/innocence-cert-renew.service", "systemd/innocence-cert-renew.timer",
)


def main() -> None:
    timestamp = datetime.now(timezone(timedelta(hours=8))).strftime("%Y%m%d-%H%M%S")
    output = ROOT / "build" / "deployment" / timestamp
    bundle = output / "bundle"
    bundle.mkdir(parents=True, exist_ok=False)
    for relative in FILES:
        source = SOURCE / relative
        data = source.read_bytes()
        assert data.decode("utf-8").encode("utf-8") == data
        if b"\r" in data or data.startswith(b"\xef\xbb\xbf"):
            raise ValueError(f"UTF-8 without BOM and LF required: {relative}")
        destination = bundle / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(data)

    backend = ROOT / "server" / "innocence-server"
    jar = backend / "target" / "innocence-server-0.0.1-SNAPSHOT.jar"
    destination = bundle / "backend" / "server.jar"
    destination.parent.mkdir()
    excluded = "BOOT-INF/classes/application-local.yml"
    with zipfile.ZipFile(jar) as original, zipfile.ZipFile(destination, "w") as target:
        if original.testzip() is not None:
            raise ValueError("Original backend JAR CRC failed")
        if excluded not in original.namelist():
            raise ValueError("Expected development config was not found; review packaging")
        for entry in original.infolist():
            if entry.filename.upper().startswith("META-INF/") and entry.filename.upper().endswith((".SF", ".RSA", ".DSA")):
                raise ValueError("Signed JAR requires a separate packaging review")
            if entry.filename != excluded:
                target.writestr(entry, original.read(entry))
    with zipfile.ZipFile(jar) as original, zipfile.ZipFile(destination) as target:
        if target.testzip() is not None:
            raise ValueError("Deploy backend JAR CRC failed")
        expected = set(original.namelist()) - {excluded}
        if set(target.namelist()) != expected:
            raise ValueError("Deploy JAR entry set differs unexpectedly")
        for name in expected:
            if SHA(original.read(name)) != SHA(target.read(name)):
                raise ValueError(f"Deploy JAR payload changed: {name}")

    frontend = ROOT / "client" / "admin_web" / "dist"
    if not (frontend / "index.html").is_file():
        raise ValueError("Build admin_web before packaging")
    for source in sorted(frontend.rglob("*")):
        if source.is_symlink():
            raise ValueError("Unexpected symlink in frontend")
        if source.is_file():
            relative = source.relative_to(frontend)
            destination = bundle / "admin-web" / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, destination)

    schema = backend / "src" / "main" / "resources" / "schema.sql"
    (bundle / "database").mkdir()
    shutil.copyfile(schema, bundle / "database" / "schema.sql")
    commit = subprocess.run(["git", "rev-parse", "HEAD"], cwd=ROOT, check=True,
                            capture_output=True, text=True).stdout.strip()
    manifest = {
        "created_at": datetime.now(timezone(timedelta(hours=8))).isoformat(),
        "source_commit": commit,
        "source_worktree_dirty": bool(subprocess.run(
            ["git", "status", "--porcelain", "--untracked-files=no"], cwd=ROOT,
            check=True, capture_output=True, text=True).stdout.strip()),
        "scope": "SSH admin and optional public IP HTTPS API; scripts never migrate a local account database",
        "original_jar_sha256": SHA(jar.read_bytes()),
        "deploy_jar_sha256": SHA((bundle / "backend" / "server.jar").read_bytes()),
        "excluded_jar_entries": [excluded],
        "schema_sha256": SHA(schema.read_bytes()),
        "files": {p.relative_to(bundle).as_posix(): SHA(p.read_bytes())
                  for p in sorted(bundle.rglob("*")) if p.is_file()},
    }
    (bundle / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
    paths = [p for p in sorted(bundle.rglob("*")) if p.is_file()]
    sums = "".join(f"{SHA(p.read_bytes())}  {p.relative_to(bundle).as_posix()}\n" for p in paths)
    (bundle / "SHA256SUMS").write_text(sums, encoding="utf-8", newline="\n")

    archive = output / "innocence-deploy.tar.gz"
    with tarfile.open(archive, "w:gz", format=tarfile.PAX_FORMAT) as target:
        for path in sorted(bundle.rglob("*")):
            if not path.is_file():
                continue
            info = target.gettarinfo(str(path), arcname=path.relative_to(bundle).as_posix())
            info.uid = info.gid = 0
            info.uname = info.gname = "root"
            info.mode = 0o644
            with path.open("rb") as stream:
                target.addfile(info, stream)
    with tarfile.open(archive) as target:
        actual = set()
        for entry in target.getmembers():
            path = Path(entry.name)
            if entry.name.startswith("/") or ".." in path.parts or not entry.isfile():
                raise ValueError("Unsafe archive entry")
            actual.add(entry.name)
            if target.extractfile(entry).read() != (bundle / entry.name).read_bytes():
                raise ValueError("Archive byte mismatch")
        if actual != {p.relative_to(bundle).as_posix() for p in bundle.rglob("*") if p.is_file()}:
            raise ValueError("Archive inventory mismatch")
    digest = SHA(archive.read_bytes())
    archive.with_name(archive.name + ".sha256").write_text(f"{digest}  {archive.name}\n", encoding="ascii", newline="\n")
    print(json.dumps({"archive": str(archive), "bytes": archive.stat().st_size,
                      "sha256": digest, "files": len(actual),
                      "jar_crc_and_payloads": "PASS", "archive_bytes": "PASS"}, ensure_ascii=False))


if __name__ == "__main__":
    main()
