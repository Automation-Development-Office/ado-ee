---
"ado-ee": patch
---

Fix CI smoke test file copy: stream project/inventory into the container via tar so Docker does not nest paths under `/runner/project/project/`.
