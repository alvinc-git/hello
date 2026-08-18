# Commit and Documentation Rules

1. **Co-authorship**: Every git commit made during paired work must include co-authorship trailer line(s), e.g.:
   `Co-authored-by: Antigravity <assistant@antigravity.ai>`

2. **Documentation Updates**: Always update relevant `*.md` documentation files (e.g. `README.md`, changelog, docs) whenever code or functionality is modified or committed.

3. **GPG Signing**: Every commit must be signed using GPG (`git commit -S ...`).

4. **Push Confirmation**: Never run `git push` automatically. Always prompt the user for permission and instructions before pushing any commits.
