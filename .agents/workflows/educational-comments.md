---
description: Automatically add educational comments to all generated IaC, config, and source code files
---

This workflow ensures that the agent always provides educational value when writing or modifying code for the user.

1. Whenever creating or modifying files (especially Configuration files like Terraform/Ansible, Docker/K8s YAMLs, or Source Code), ALWAYS include extremely detailed, Chinese educational inline comments.
2. The user is a Senior engineer learning these architectures, so focus the comments on "Why" we configure it this way, rather than just "What" it does.
3. Explain the industry best practices, the pain points it solves in production, and how it fits into the broader CI/CD pipeline or High Availability architecture.
4. Treat every code generation as an opportunity to provide a mini-tutorial. Do not generate naked configuration files.
