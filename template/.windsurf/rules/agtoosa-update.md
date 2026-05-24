---
trigger: user_prompt
description: "AgToosa: sync workflows to the latest baseline"
---

When executing `/agtoosa-update`, follow `Docs/AgToosa_Update.md` precisely.

**Contract:** Detect → Plan → Apply → Verify (ask-then-apply when drift is detected). Only `check` is read-only. Apply uses `agtoosa.sh --update` after explicit approval.