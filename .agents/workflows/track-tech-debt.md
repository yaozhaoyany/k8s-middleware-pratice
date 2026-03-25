---
description: Track tech debt and shortcuts in TODO.md whenever making a compromise for speed
---

Whenever making a compromise, shortcut, or "good enough for now" decision during code generation, you MUST:

1. Log the shortcut in the project root file `TODO.md` under the appropriate section (Terraform, Ansible, K8s, Java, etc.).
2. Each entry must include:
   - The affected file path
   - A clear description of the problem (why it's a shortcut)
   - The correct production-grade solution
   - A suggested priority or timeline for fixing it
3. Also add an inline comment at the shortcut location in the source code itself, prefixed with `# TODO:` or `// TODO:`, briefly referencing the issue.
4. This ensures that no technical debt is silently accumulated — every compromise is visible and traceable.
