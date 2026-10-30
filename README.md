# wilds-workspace

Development setup for WILDS, the Weizmann Institute Lowell Discovery Spectrograph: the
VS Code workspace that groups the project repos, and a script that builds the tree around it.

## Setup

```bash
mkdir WILDS && cd WILDS
git clone https://github.com/The-WILDS-Project/wilds-workspace.git
wilds-workspace/setup.sh
code wilds-workspace/WILDS.code-workspace
```

`setup.sh` clones the other repos next to this one and creates one shared Python 3.14
venv at `WILDS/.venv` with every package installed editable, so cross-repo imports
resolve. It needs [uv](https://docs.astral.sh/uv/) and is safe to re-run.

```
WILDS/
├── .venv/                  shared venv (created by setup.sh)
├── wilds-workspace/        this repo
├── wilds-bridge/           LDT ActiveMQ bridge
├── wilds-control/          FastAPI backend
├── wilds-science-camera/   Archon science-camera control
├── wilds-solving/          plate solving
└── wilds-claude/           Claude's project memory and notes
```

## Notes

- **`wilds` is a PEP 420 namespace package.** No repo may add `src/wilds/__init__.py`;
  it would shadow the others.
- **Imports are organised by ruff on save,** using each repo's own `pyproject.toml`
  (`known-first-party = ["wilds"]`).
- **Credentials stay out of git.** Tokens such as the LDT Confluence one live in
  `WILDS/.wilds-vault/`, outside every repo — never commit them here.
