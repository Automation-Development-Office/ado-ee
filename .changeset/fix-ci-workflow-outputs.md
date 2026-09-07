---
"ado-ee": patch
---

Fix release and infra.ado bump workflows: pass image tags via step outputs instead of `GITHUB_ENV`, and load bump reviewers from the repo variable via the GitHub API.
