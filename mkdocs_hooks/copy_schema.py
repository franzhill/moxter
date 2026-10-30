"""Publish the Moxter JSON schema (=> support for moxtures in IDE) in the MkDocs site for reference."""

from pathlib import Path
import shutil


def on_post_build(config, **kwargs):
    project_root = Path(__file__).resolve().parent.parent
    schema_source = project_root / "src" / "main" / "resources" / "moxture-schema.json"
    schema_target = Path(config["site_dir"]) / "schema" / "moxture-schema.json"
    schema_target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(schema_source, schema_target)