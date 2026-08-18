# Description
Use this rule whenever generating git commit messages, executing commits, or summarizing workspace changes.

# Instructions
When asked to commit changes or generate a commit message, you must follow these exact steps:

1. **Analyze:** Review the staged changes (or un-staged if requested) to understand the context.
2. **Format:** Use Conventional Commits (e.g., `feat:`, `fix:`, `chore:`). 
3. **Co-authorship:** You MUST append the following trailer to the very end of the commit message body, separated by a blank line:
   `Co-authored-by: Google Antigravity <antigravity@google.com>`
4. **Report:** After successfully committing, output a brief summary to the chat in this format:
   - **Commit:** `<short hash>`
   - **Type:** `<type>`
   - **Summary:** `<brief 1-sentence summary of what was done>`
