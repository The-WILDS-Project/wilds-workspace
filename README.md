# workspace

Development setup for WILDS, the Weizmann Institute Lowell Discovery Spectrograph: the
VS Code workspace that groups the project repos, and a script that builds the tree around it.

## Setup

```bash
mkdir WILDS && cd WILDS
git clone https://github.com/The-WILDS-Project/wilds-workspace.git workspace
workspace/setup.sh
code workspace/WILDS.code-workspace
```

`setup.sh` clones the other repos next to this one (folders without the `wilds-` prefix; the GitHub repos keep it) and creates one shared Python 3.14
venv at `WILDS/.venv` with every package installed editable, so cross-repo imports
resolve. It needs [uv](https://docs.astral.sh/uv/) and is safe to re-run.

```
WILDS/
├── .venv/             shared venv (created by setup.sh)
├── .vault/            secrets, outside every repo (never committed)
├── workspace/         this repo
├── bridge/            LDT ActiveMQ bridge
├── control/           FastAPI backend
├── gui/               Django front end
├── science-camera/    Archon science-camera control
├── solving/           plate solving
└── claude/            Claude's project memory and notes
```

## Notes

- **`wilds` is a PEP 420 namespace package.** No repo may add `src/wilds/__init__.py`;
  it would shadow the others.
- **Imports are organised by ruff on save,** using each repo's own `pyproject.toml`
  (`known-first-party = ["wilds"]`).
- **Credentials stay out of git.** Tokens such as the LDT Confluence one live in
  `WILDS/.vault/`, outside every repo — never commit them here.

## Boot services (Linux, systemd)

`root/` mirrors the target filesystem; `install-services.sh` copies it into place.

| File in `root/` | Purpose |
|---|---|
| `etc/systemd/system/wilds.service` | the one unit to enable and start: brings up control, then the GUI |
| `etc/systemd/system/wilds-control.service` | wilds-control on `:8001` |
| `etc/systemd/system/wilds-gui.service` | wilds-gui on `:8000`, started after control |
| `etc/wilds/wilds.env` | shared environment (GUI secret key, control URL) |
| `etc/wilds/config.toml` | wilds-control configuration: opmode, TO presence timeout, site, filing (staging and share) |
| `etc/wilds/passphrases.toml` | the engineering and TO passphrases, in a file of their own (root-owned, mode 0640) |
| `usr/lib/sysusers.d/wilds.conf` | the `wilds` service account |

The units expect the setup tree at `/opt/wilds` (the `WILDS/` layout above, owned by `wilds`).

```bash
sudo ./install-services.sh        # then edit /etc/wilds/wilds.env
sudo systemctl start wilds.service
```
