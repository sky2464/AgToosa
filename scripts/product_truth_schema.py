"""Bounded JSON Schema subset used by the Product Truth v1 validator."""

from __future__ import annotations

import datetime as dt
import json
import re
from pathlib import Path
from typing import Callable

MAX_SCHEMA_BYTES = 262_144


def _duplicate_guard(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate schema field: {key}")
        result[key] = value
    return result


def _reject_nonfinite(value: str):
    raise ValueError(f"non-finite schema number forbidden: {value}")


def load_schema(path: Path, add: Callable[[str], None]) -> dict | None:
    """Load the local schema as inert, size-bounded JSON."""
    try:
        if path.stat().st_size > MAX_SCHEMA_BYTES:
            add("schema exceeds bounded-size limit")
            return None
        value = json.loads(path.read_text(encoding="utf-8"),
                           object_pairs_hook=_duplicate_guard,
                           parse_constant=_reject_nonfinite)
    except (OSError, UnicodeError, json.JSONDecodeError, ValueError) as exc:
        add(f"schema load failed: {exc}")
        return None
    if not isinstance(value, dict):
        add("schema root must be an object")
        return None
    return value


def _resolve_ref(root_schema: dict, reference: str) -> dict | None:
    if not reference.startswith("#/"):
        return None
    value = root_schema
    for token in reference[2:].split("/"):
        token = token.replace("~1", "/").replace("~0", "~")
        if not isinstance(value, dict) or token not in value:
            return None
        value = value[token]
    return value if isinstance(value, dict) else None


def _type_matches(value, expected: str) -> bool:
    checks = {
        "object": lambda item: isinstance(item, dict),
        "array": lambda item: isinstance(item, list),
        "string": lambda item: isinstance(item, str),
        "boolean": lambda item: isinstance(item, bool),
        "integer": lambda item: isinstance(item, int) and not isinstance(item, bool),
        "number": lambda item: isinstance(item, (int, float)) and not isinstance(item, bool),
        "null": lambda item: item is None,
    }
    return expected in checks and checks[expected](value)


def validate_instance(value, schema: dict, root_schema: dict,
                      add: Callable[[str], None], where: str = "$",
                      depth: int = 0) -> None:
    """Validate the schema features used by product-truth-v1.schema.json."""
    if depth > 32:
        add(f"{where}: schema validation depth exceeded")
        return
    if "$ref" in schema:
        target = _resolve_ref(root_schema, schema["$ref"])
        if target is None:
            add(f"{where}: unresolved schema reference {schema['$ref']!r}")
            return
        validate_instance(value, target, root_schema, add, where, depth + 1)

    expected = schema.get("type")
    if expected is not None:
        choices = expected if isinstance(expected, list) else [expected]
        if not any(isinstance(item, str) and _type_matches(value, item)
                   for item in choices):
            add(f"{where}: expected schema type {expected!r}")
            return
    if "const" in schema and value != schema["const"]:
        add(f"{where}: value does not match schema const")
    if "enum" in schema and value not in schema["enum"]:
        add(f"{where}: value {value!r} is outside the schema enum")

    if isinstance(value, dict):
        required = schema.get("required", [])
        for key in required:
            if key not in value:
                add(f"{where}: missing schema-required field {key!r}")
        properties = schema.get("properties", {})
        patterns = schema.get("patternProperties", {})
        property_names = schema.get("propertyNames")
        additional = schema.get("additionalProperties", True)
        for key, child in value.items():
            if property_names:
                validate_instance(key, property_names, root_schema, add,
                                  f"{where}.<property-name>", depth + 1)
            matched = False
            if key in properties:
                matched = True
                validate_instance(child, properties[key], root_schema, add,
                                  f"{where}.{key}", depth + 1)
            for pattern, child_schema in patterns.items():
                try:
                    pattern_matches = re.search(pattern, key) is not None
                except re.error as exc:
                    add(f"schema pattern is invalid: {exc}")
                    return
                if pattern_matches:
                    matched = True
                    validate_instance(child, child_schema, root_schema, add,
                                      f"{where}.{key}", depth + 1)
            if not matched and additional is False:
                add(f"{where}: unknown schema field {key!r}")
            elif not matched and isinstance(additional, dict):
                validate_instance(child, additional, root_schema, add,
                                  f"{where}.{key}", depth + 1)

    if isinstance(value, list):
        if len(value) < schema.get("minItems", 0):
            add(f"{where}: collection is below schema minimum")
        if len(value) > schema.get("maxItems", len(value)):
            add(f"{where}: collection exceeds schema maximum")
        if schema.get("uniqueItems"):
            encoded = [json.dumps(item, sort_keys=True, separators=(",", ":"),
                                  ensure_ascii=False) for item in value]
            if len(encoded) != len(set(encoded)):
                add(f"{where}: collection violates schema uniqueness")
        item_schema = schema.get("items")
        if isinstance(item_schema, dict):
            for index, child in enumerate(value):
                validate_instance(child, item_schema, root_schema, add,
                                  f"{where}[{index}]", depth + 1)

    if isinstance(value, str):
        if len(value) < schema.get("minLength", 0):
            add(f"{where}: string is below schema minimum length")
        if len(value) > schema.get("maxLength", len(value)):
            add(f"{where}: string exceeds schema maximum length")
        if "pattern" in schema:
            try:
                matches = re.search(schema["pattern"], value) is not None
            except re.error as exc:
                add(f"schema pattern is invalid: {exc}")
                return
            if not matches:
                add(f"{where}: string does not match schema pattern")
        if schema.get("format") == "date":
            try:
                if re.fullmatch(r"[0-9]{4}-[0-9]{2}-[0-9]{2}", value) is None:
                    raise ValueError("date must use YYYY-MM-DD")
                dt.date.fromisoformat(value)
            except ValueError:
                add(f"{where}: invalid schema date")

    if isinstance(value, (int, float)) and not isinstance(value, bool):
        if value < schema.get("minimum", value):
            add(f"{where}: number is below schema minimum")
        if value > schema.get("maximum", value):
            add(f"{where}: number exceeds schema maximum")
