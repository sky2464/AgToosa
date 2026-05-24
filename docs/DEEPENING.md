# Deep Modules — Design Reference

> **Path note:** Examples use `docs/` for **Maintainer Dogfood Mode**; generated projects use `Docs/` — see `docs/agtoosa-maintainer.md` → Path conventions.

A deep module provides a simple, narrow interface that hides a rich, complex implementation. A shallow module has a complex interface relative to the functionality it provides. Prefer deep modules.

## Signs of Shallow Modules (Fix These)

| Pattern | Problem | Fix |
|---------|---------|-----|
| Pass-through function | Adds no logic; just delegates | Eliminate the wrapper or add real behaviour |
| One-line service method | Interface complexity equals implementation complexity | Merge into caller or enrich with logic |
| "Manager", "Handler", "Helper" class | Name signals no clear domain concept | Name by what it does, not what it manages |
| Getter/setter for every field | Exposes internals through interface | Encapsulate; expose behaviour, not data |
| Config object passed everywhere | Caller controls too much | Push decisions into the module |

## Deep Module Checklist

When designing or reviewing a module, ask:

1. **Can implementation details be hidden behind a simpler interface?**
   - Caller should not know how the module works, only what it does.

2. **Does the interface reveal WHAT, not HOW?**
   - `sendWelcomeEmail(user)` is deep. `buildEmailPayload(user, template, smtp)` is shallow.

3. **Is the abstraction level consistent?**
   - All methods on an interface should operate at the same level of abstraction.

4. **Does adding a new caller require changing the interface?**
   - If yes, the interface is leaking implementation.

5. **Is error handling pushed into the module?**
   - Callers should not handle errors the module could recover from internally.

## Application in AgToosa

- `/agtoosa-review arch` uses this checklist to identify shallow modules during architecture reviews.
- When a shallow module is found: file a refactor task in Linear, reference this document.
- Reference alongside `docs/LANGUAGE.md` — deep modules should use domain language at every level.
