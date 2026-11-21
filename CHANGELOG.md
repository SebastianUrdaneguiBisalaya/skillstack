# Changelog

All notable changes are documented here. Format based on [Keep a Changelog](https://keepachangelog.com/); versions are git tags (`vX.Y.Z`).

## [0.1.0] - 2026-11-21

### Added
- `github` skill: task sizing, issue and PR templates, commit conventions, allowed `gh` commands, and validation/guard/create scripts.
- `install.sh`: skill and agent selection, `.agents` install with symlinks for `.claude`, `.codex`, `.cursor`, `.gemini`, `--global`, `--target`, `--uninstall`.
- Install without cloning (`curl | bash`), defaulting to the latest tag, with `--version`.
- Git hooks (`commit-msg`, `pre-push`) and `scripts/validate-skills.sh`.
- README, CONTRIBUTING, SECURITY.
