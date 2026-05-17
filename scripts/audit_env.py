#!/usr/bin/env python3
import argparse
import json
import os
import platform
import shutil
import subprocess
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

TERMINAL_TOOLS = [
    {"key": "git", "commands": ["git"], "label": "Git"},
    {"key": "curl", "commands": ["curl"], "label": "curl"},
    {"key": "zsh", "commands": ["zsh"], "label": "Zsh"},
    {"key": "starship", "commands": ["starship"], "label": "Starship"},
    {"key": "fzf", "commands": ["fzf"], "label": "fzf"},
    {"key": "zoxide", "commands": ["zoxide"], "label": "zoxide"},
    {"key": "eza", "commands": ["eza", "exa"], "label": "eza/exa"},
    {"key": "bat", "commands": ["bat", "batcat"], "label": "bat"},
    {"key": "fd", "commands": ["fd", "fdfind"], "label": "fd"},
    {"key": "ripgrep", "commands": ["rg"], "label": "ripgrep"},
    {"key": "node", "commands": ["node"], "label": "Node.js"},
    {"key": "npm", "commands": ["npm"], "label": "npm"},
    {"key": "uv", "commands": ["uv"], "label": "uv"},
    {"key": "pipx", "commands": ["pipx"], "label": "pipx"},
]

AGENT_TOOLS = [
    {"key": "hermes", "commands": ["hermes"], "label": "Hermes Agent"},
    {"key": "opencode", "commands": ["opencode"], "label": "OpenCode CLI"},
    {"key": "claude", "commands": ["claude"], "label": "Claude Code CLI"},
    {"key": "codex", "commands": ["codex"], "label": "OpenAI Codex CLI"},
    {"key": "aider", "commands": ["aider"], "label": "Aider"},
    {"key": "gemini", "commands": ["gemini"], "label": "Gemini CLI"},
    {"key": "ollama", "commands": ["ollama"], "label": "Ollama"},
    {"key": "gh", "commands": ["gh"], "label": "GitHub CLI"},
    {"key": "python3", "commands": ["python3", "python"], "label": "Python"},
]

PACKAGE_MAP: Dict[str, Dict[str, Optional[str]]] = {
    "apt": {
        "git": "git",
        "curl": "curl",
        "zsh": "zsh",
        "starship": None,
        "fzf": "fzf",
        "zoxide": "zoxide",
        "eza": None,
        "bat": "bat",
        "fd": "fd-find",
        "ripgrep": "ripgrep",
        "node": "nodejs",
        "npm": "npm",
        "uv": "uv",
        "pipx": "pipx",
        "gh": None,
    },
    "dnf": {
        "git": "git",
        "curl": "curl",
        "zsh": "zsh",
        "starship": "starship",
        "fzf": "fzf",
        "zoxide": "zoxide",
        "eza": "eza",
        "bat": "bat",
        "fd": "fd-find",
        "ripgrep": "ripgrep",
        "node": "nodejs",
        "npm": "npm",
        "uv": "uv",
        "pipx": "pipx",
        "gh": "gh",
    },
    "yum": {
        "git": "git",
        "curl": "curl",
        "zsh": "zsh",
        "starship": None,
        "fzf": None,
        "zoxide": None,
        "eza": None,
        "bat": None,
        "fd": None,
        "ripgrep": "ripgrep",
        "node": "nodejs",
        "npm": "npm",
        "uv": None,
        "pipx": "pipx",
        "gh": None,
    },
    "pacman": {
        "git": "git",
        "curl": "curl",
        "zsh": "zsh",
        "starship": "starship",
        "fzf": "fzf",
        "zoxide": "zoxide",
        "eza": "eza",
        "bat": "bat",
        "fd": "fd",
        "ripgrep": "ripgrep",
        "node": "nodejs",
        "npm": "npm",
        "uv": "uv",
        "pipx": "python-pipx",
        "gh": "github-cli",
    },
    "brew": {
        "git": "git",
        "curl": "curl",
        "zsh": "zsh",
        "starship": "starship",
        "fzf": "fzf",
        "zoxide": "zoxide",
        "eza": "eza",
        "bat": "bat",
        "fd": "fd",
        "ripgrep": "ripgrep",
        "node": "node",
        "npm": "node",
        "uv": "uv",
        "pipx": "pipx",
        "gh": "gh",
    },
    "winget": {
        "git": "Git.Git",
        "curl": None,
        "zsh": None,
        "starship": "Starship.Starship",
        "fzf": None,
        "zoxide": None,
        "eza": None,
        "bat": None,
        "fd": None,
        "ripgrep": None,
        "node": "OpenJS.NodeJS.LTS",
        "npm": "OpenJS.NodeJS.LTS",
        "uv": "astral-sh.uv",
        "pipx": None,
        "gh": "GitHub.cli",
    },
    "choco": {
        "git": "git",
        "curl": "curl",
        "zsh": None,
        "starship": "starship",
        "fzf": "fzf",
        "zoxide": "zoxide",
        "eza": "eza",
        "bat": "bat",
        "fd": "fd",
        "ripgrep": "ripgrep",
        "node": "nodejs-lts",
        "npm": "nodejs-lts",
        "uv": "uv",
        "pipx": "pipx",
        "gh": "gh",
    },
    "scoop": {
        "git": "git",
        "curl": "curl",
        "zsh": None,
        "starship": "starship",
        "fzf": "fzf",
        "zoxide": "zoxide",
        "eza": "eza",
        "bat": "bat",
        "fd": "fd",
        "ripgrep": "ripgrep",
        "node": "nodejs-lts",
        "npm": "nodejs-lts",
        "uv": "uv",
        "pipx": "pipx",
        "gh": "gh",
    },
}

AGENT_INSTALLERS: Dict[str, List[Dict[str, str]]] = {
    "hermes": [
        {"id": "unix-script", "description": "Official Hermes install script (Unix/WSL/macOS)", "command": "curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash"}
    ],
    "opencode": [
        {"id": "npm", "description": "Install OpenCode via npm", "command": "npm install -g opencode-ai@latest"},
        {"id": "brew", "description": "Install OpenCode via Homebrew", "command": "brew install anomalyco/tap/opencode"},
    ],
    "claude": [
        {"id": "npm", "description": "Install Claude Code via npm", "command": "npm install -g @anthropic-ai/claude-code"}
    ],
    "codex": [
        {"id": "npm", "description": "Install Codex via npm", "command": "npm install -g @openai/codex"}
    ],
    "aider": [
        {"id": "uv-tool", "description": "Install Aider with uv tool", "command": "uv tool install aider-chat"},
        {"id": "pipx", "description": "Install Aider with pipx", "command": "pipx install aider-chat"},
    ],
    "gemini": [
        {"id": "npm", "description": "Install Gemini CLI via npm", "command": "npm install -g @google/gemini-cli"}
    ],
    "ollama": [
        {"id": "unix-script", "description": "Install Ollama with the official script", "command": "curl -fsSL https://ollama.com/install.sh | sh"},
        {"id": "winget", "description": "Install Ollama via winget", "command": "winget install --id Ollama.Ollama --accept-package-agreements --accept-source-agreements"},
    ],
}

NERD_FONT_RECOMMENDATIONS = {
    "font_name": "JetBrainsMono Nerd Font",
    "windows_terminal": "Use Windows Terminal with JetBrainsMono Nerd Font for the best experience on Windows/WSL.",
    "unix_terminal": "Use a Nerd Font (for example JetBrainsMono Nerd Font) in your terminal to display prompt and file icons correctly.",
    "unix_install_hint": "Download a Nerd Font release and install the .ttf files into ~/.local/share/fonts, then run fc-cache -fv.",
}

ENV_AUTH_KEYS = {
    "hermes": ["OPENROUTER_API_KEY", "ANTHROPIC_API_KEY", "OPENAI_API_KEY", "GOOGLE_API_KEY", "GEMINI_API_KEY", "DEEPSEEK_API_KEY"],
    "opencode": ["OPENROUTER_API_KEY", "ANTHROPIC_API_KEY", "OPENAI_API_KEY", "GOOGLE_API_KEY", "GEMINI_API_KEY", "DEEPSEEK_API_KEY"],
    "claude": ["ANTHROPIC_API_KEY"],
    "codex": ["OPENAI_API_KEY"],
    "aider": ["OPENAI_API_KEY", "ANTHROPIC_API_KEY", "OPENROUTER_API_KEY", "GEMINI_API_KEY", "GOOGLE_API_KEY"],
    "gemini": ["GOOGLE_API_KEY", "GEMINI_API_KEY"],
}


def run(cmd: List[str], timeout: int = 10) -> Tuple[int, str]:
    try:
        out = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        text = (out.stdout or out.stderr or "").strip()
        return out.returncode, text
    except Exception as exc:
        return 1, str(exc)


def detect_os() -> Dict[str, Any]:
    system = platform.system()
    is_wsl = False
    distro = None
    distro_like = None

    if os.path.exists("/proc/version"):
        try:
            pv = Path("/proc/version").read_text(encoding="utf-8", errors="ignore")
            is_wsl = "microsoft" in pv.lower() or "wsl" in pv.lower() or bool(os.environ.get("WSLENV"))
        except Exception:
            pass

    if os.path.exists("/etc/os-release"):
        try:
            data: Dict[str, str] = {}
            for line in Path("/etc/os-release").read_text(encoding="utf-8", errors="ignore").splitlines():
                if "=" in line:
                    k, v = line.split("=", 1)
                    data[k] = v.strip().strip('"')
            distro = data.get("NAME")
            distro_like = data.get("ID_LIKE") or data.get("ID")
        except Exception:
            pass

    return {
        "system": system,
        "is_wsl": is_wsl,
        "distro": distro,
        "distro_like": distro_like,
        "release": platform.release(),
        "machine": platform.machine(),
        "home": str(Path.home()),
    }


def detect_package_managers() -> Dict[str, bool]:
    candidates = ["apt", "apt-get", "dnf", "yum", "pacman", "brew", "winget", "choco", "scoop"]
    return {name: bool(shutil.which(name)) for name in candidates}


def detect_shells() -> Dict[str, Optional[str]]:
    current_shell = os.environ.get("SHELL") or os.environ.get("COMSPEC")
    return {
        "current_shell": current_shell,
        "bash": shutil.which("bash"),
        "zsh": shutil.which("zsh"),
        "fish": shutil.which("fish"),
        "pwsh": shutil.which("pwsh"),
        "powershell": shutil.which("powershell"),
    }


def check_tool(entry: Dict[str, Any]) -> Dict[str, Any]:
    for cmd in entry["commands"]:
        path = shutil.which(cmd)
        if path:
            rc, version_text = run([cmd, "--version"])
            if rc != 0 and cmd == "hermes":
                rc, version_text = run([cmd, "--help"])
            version = version_text.splitlines()[0] if version_text else None
            return {
                "installed": True,
                "command": cmd,
                "path": path,
                "version": version,
                "label": entry["label"],
            }
    return {
        "installed": False,
        "command": None,
        "path": None,
        "version": None,
        "label": entry["label"],
    }


def recommend_package_manager(os_info: Dict[str, Any], managers: Dict[str, bool]) -> str:
    system = os_info["system"]
    distro_like = (os_info.get("distro_like") or "").lower()
    if system == "Darwin" and managers.get("brew"):
        return "brew"
    if system == "Windows":
        if managers.get("winget"):
            return "winget"
        if managers.get("choco"):
            return "choco"
        if managers.get("scoop"):
            return "scoop"
        return "manual"
    if "arch" in distro_like and managers.get("pacman"):
        return "pacman"
    if any(x in distro_like for x in ["debian", "ubuntu"]) and (managers.get("apt") or managers.get("apt-get")):
        return "apt"
    if any(x in distro_like for x in ["rhel", "fedora", "centos", "rocky", "almalinux"]) and managers.get("dnf"):
        return "dnf"
    if managers.get("yum"):
        return "yum"
    if managers.get("brew"):
        return "brew"
    return "manual"


def env_auth_status(tool_key: str) -> Dict[str, Any]:
    keys = ENV_AUTH_KEYS.get(tool_key, [])
    found = [key for key in keys if os.environ.get(key)]
    return {
        "configured": bool(found),
        "method": "environment" if found else None,
        "details": found,
    }


def detect_auth_status(tool_key: str, installed: bool) -> Dict[str, Any]:
    if not installed:
        return {"status": "not_installed", "configured": False, "details": []}

    env_status = env_auth_status(tool_key)
    home = Path.home()

    if tool_key == "claude":
        rc, out = run(["claude", "auth", "status", "--json"])
        if rc == 0 and out:
            try:
                data = json.loads(out)
                text = json.dumps(data).lower()
                configured = any(word in text for word in ["active", "authenticated", "logged_in", "valid"])
                return {"status": "configured" if configured else "unknown", "configured": configured, "method": "cli", "details": data}
            except Exception:
                pass
        rc, out = run(["claude", "auth", "status", "--text"])
        text = (out or "").lower()
        configured = any(word in text for word in ["authenticated", "logged in", "active"]) or env_status["configured"]
        return {"status": "configured" if configured else "needs_login", "configured": configured, "method": "cli_or_env" if configured else None, "details": [out] if out else env_status["details"]}

    if tool_key == "codex":
        auth_file = home / ".codex" / "auth.json"
        configured = env_status["configured"] or auth_file.exists()
        details: List[str] = []
        if env_status["configured"]:
            details.extend(env_status["details"])
        if auth_file.exists():
            details.append(str(auth_file))
        return {"status": "configured" if configured else "needs_login", "configured": configured, "method": "env_or_auth_file" if configured else None, "details": details}

    if tool_key == "opencode":
        rc, out = run(["opencode", "auth", "list"])
        text = (out or "").lower()
        configured = env_status["configured"] or (rc == 0 and bool(out.strip()) and "no" not in text[:80])
        details = env_status["details"][:]
        if out:
            details.append(out.splitlines()[0])
        return {"status": "configured" if configured else "needs_login", "configured": configured, "method": "auth_list_or_env" if configured else None, "details": details}

    if tool_key == "hermes":
        config_dir = Path(os.environ.get("HERMES_HOME", str(home / ".hermes")))
        config_file = config_dir / "config.yaml"
        env_file = config_dir / ".env"
        rc, out = run(["hermes", "auth", "list"])
        configured = config_file.exists() or env_file.exists() or env_status["configured"] or (rc == 0 and bool(out.strip()))
        details = []
        if config_file.exists():
            details.append(str(config_file))
        if env_file.exists():
            details.append(str(env_file))
        if env_status["configured"]:
            details.extend(env_status["details"])
        if out:
            details.append(out.splitlines()[0])
        return {"status": "configured" if configured else "needs_setup", "configured": configured, "method": "config_or_auth_list" if configured else None, "details": details}

    if tool_key == "aider":
        config_files = [home / ".aider.conf.yml", home / ".config" / "aider.conf.yml"]
        existing = [str(p) for p in config_files if p.exists()]
        configured = env_status["configured"] or bool(existing)
        return {"status": "configured" if configured else "needs_setup", "configured": configured, "method": "env_or_config" if configured else None, "details": env_status["details"] + existing}

    if tool_key == "gemini":
        config_dirs = [home / ".config" / "gemini-cli", home / ".gemini"]
        existing = [str(p) for p in config_dirs if p.exists()]
        configured = env_status["configured"] or bool(existing)
        return {"status": "configured" if configured else "needs_setup", "configured": configured, "method": "env_or_config_dir" if configured else None, "details": env_status["details"] + existing}

    if tool_key == "ollama":
        rc, out = run(["ollama", "list"])
        configured = rc == 0
        return {"status": "ready" if configured else "installed", "configured": configured, "method": "local_runtime", "details": [out.splitlines()[0]] if out else []}

    return {"status": "installed", "configured": True, "method": None, "details": []}


def terminal_recommendations(os_info: Dict[str, Any]) -> List[str]:
    system = os_info["system"]
    recs = []
    if os_info["is_wsl"]:
        recs.append("Use Windows Terminal as the frontend and WSL as the Unix environment.")
        recs.append(NERD_FONT_RECOMMENDATIONS["windows_terminal"])
    elif system == "Windows":
        recs.append("Use Windows Terminal or PowerShell 7 for the best native Windows experience.")
        recs.append("If you want Zsh-first workflows, prefer WSL instead of native Windows shell customization.")
        recs.append(NERD_FONT_RECOMMENDATIONS["windows_terminal"])
    elif system == "Darwin":
        recs.append("Use iTerm2, Ghostty, Warp, or the default Terminal with a Nerd Font configured.")
        recs.append(NERD_FONT_RECOMMENDATIONS["unix_terminal"])
    else:
        recs.append("Use a modern terminal emulator such as Kitty, WezTerm, Ghostty, Alacritty, or your distro's default terminal.")
        recs.append(NERD_FONT_RECOMMENDATIONS["unix_terminal"])
    return recs


def build_package_plan(package_manager: str, terminal: Dict[str, Any]) -> Dict[str, Any]:
    package_map = PACKAGE_MAP.get(package_manager, {})
    installable: List[Dict[str, str]] = []
    manual: List[str] = []
    for key, data in terminal.items():
        if data["installed"]:
            continue
        mapped = package_map.get(key)
        if mapped:
            installable.append({"tool": key, "package": mapped})
        else:
            manual.append(key)
    return {"installable": installable, "manual": manual}


def build_agent_plan(agents: Dict[str, Any]) -> List[Dict[str, Any]]:
    plan = []
    for key, data in agents.items():
        if data["installed"]:
            continue
        installers = AGENT_INSTALLERS.get(key, [])
        if installers:
            plan.append({"tool": key, "installers": installers})
    return plan


def build_recommendations(os_info: Dict[str, Any], terminal: Dict[str, Any], agents: Dict[str, Any], auth: Dict[str, Any], package_manager: str) -> List[str]:
    recs = []
    missing_terminal = [key for key, data in terminal.items() if not data["installed"]]
    missing_agents = [key for key, data in agents.items() if not data["installed"]]
    unauthenticated = [key for key, data in auth.items() if data.get("status") in {"needs_login", "needs_setup"}]

    if missing_terminal:
        recs.append(f"Install missing terminal tools with {package_manager} where possible: {', '.join(missing_terminal)}")
    if missing_agents:
        recs.append(f"Install optional agent CLIs based on actual need: {', '.join(missing_agents)}")
    if unauthenticated:
        recs.append(f"These installed agent CLIs still need authentication or setup: {', '.join(unauthenticated)}")
    if terminal.get("zsh", {}).get("installed"):
        recs.append("Zsh is already present; changing the default shell should remain optional and explicit.")
    else:
        recs.append("Install Zsh before creating or applying any Zsh configuration scaffold.")
    if (not terminal.get("node", {}).get("installed")) or (not terminal.get("npm", {}).get("installed")):
        recs.append("Node.js/npm are missing; npm-based CLIs such as Claude Code, Codex, OpenCode, and Gemini cannot be installed yet.")
    if (not terminal.get("uv", {}).get("installed")) and (not terminal.get("pipx", {}).get("installed")):
        recs.append("Install uv or pipx if you want a cleaner Python-based CLI workflow for tools like Aider.")
    recs.extend(terminal_recommendations(os_info))
    return recs


def render_markdown(result: Dict[str, Any]) -> str:
    lines: List[str] = []
    os_info = result["os"]
    lines.append("# Terminal Setup Audit and Plan")
    lines.append("")
    lines.append("## Platform")
    lines.append(f"- System: {os_info['system']}")
    lines.append(f"- Release: {os_info['release']}")
    lines.append(f"- Machine: {os_info['machine']}")
    lines.append(f"- WSL: {'yes' if os_info['is_wsl'] else 'no'}")
    if os_info.get("distro"):
        lines.append(f"- Distro: {os_info['distro']}")
    if os_info.get("distro_like"):
        lines.append(f"- Distro-like: {os_info['distro_like']}")
    lines.append("")
    lines.append("## Recommended Package Manager")
    lines.append(f"- {result['recommended_package_manager']}")
    lines.append("")
    lines.append("## Terminal Tools")
    for key, data in result["terminal_tools"].items():
        status = "installed" if data["installed"] else "missing"
        version = f" — {data['version']}" if data.get("version") else ""
        lines.append(f"- {data['label']}: {status}{version}")
    lines.append("")
    lines.append("## Agent CLIs")
    for key, data in result["agent_tools"].items():
        auth = result["auth"].get(key)
        auth_suffix = f" | auth: {auth['status']}" if auth else ""
        version = f" — {data['version']}" if data.get("version") else ""
        lines.append(f"- {data['label']}: {'installed' if data['installed'] else 'missing'}{version}{auth_suffix}")
    lines.append("")
    lines.append("## Install Plan")
    package_plan = result["install_plan"]["package_plan"]
    if package_plan["installable"]:
        lines.append("### Installable via package manager")
        for item in package_plan["installable"]:
            lines.append(f"- {item['tool']}: `{item['package']}`")
    if package_plan["manual"]:
        lines.append("### Requires manual or dedicated installer")
        for item in package_plan["manual"]:
            lines.append(f"- {item}")
    agent_plan = result["install_plan"]["agent_plan"]
    if agent_plan:
        lines.append("### Agent installer commands")
        for item in agent_plan:
            lines.append(f"- {item['tool']}")
            for installer in item["installers"]:
                lines.append(f"  - {installer['description']}: `{installer['command']}`")
    lines.append("")
    lines.append("## Terminal Recommendations")
    for rec in result["terminal_recommendations"]:
        lines.append(f"- {rec}")
    lines.append("")
    lines.append("## Recommendations")
    for rec in result["recommendations"]:
        lines.append(f"- {rec}")
    lines.append("")
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description="Audit terminal and agent CLI environment")
    parser.add_argument("--json", action="store_true", dest="as_json", help="Print JSON output")
    parser.add_argument("--markdown", action="store_true", help="Print the final plan in Markdown")
    parser.add_argument("--plan-md", type=str, help="Write the final plan in Markdown to the given path")
    args = parser.parse_args()

    os_info = detect_os()
    managers = detect_package_managers()
    shells = detect_shells()
    terminal = {entry["key"]: check_tool(entry) for entry in TERMINAL_TOOLS}
    agents = {entry["key"]: check_tool(entry) for entry in AGENT_TOOLS}
    package_manager = recommend_package_manager(os_info, managers)
    auth = {key: detect_auth_status(key, data["installed"]) for key, data in agents.items()}
    package_plan = build_package_plan(package_manager, terminal)
    agent_plan = build_agent_plan(agents)
    recs = build_recommendations(os_info, terminal, agents, auth, package_manager)

    result = {
        "os": os_info,
        "package_managers": managers,
        "recommended_package_manager": package_manager,
        "shells": shells,
        "terminal_tools": terminal,
        "agent_tools": agents,
        "auth": auth,
        "package_map": PACKAGE_MAP.get(package_manager, {}),
        "terminal_recommendations": terminal_recommendations(os_info),
        "font_recommendations": NERD_FONT_RECOMMENDATIONS,
        "install_plan": {
            "package_plan": package_plan,
            "agent_plan": agent_plan,
        },
        "recommendations": recs,
    }

    markdown = render_markdown(result)
    if args.plan_md:
        target = Path(args.plan_md)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(markdown, encoding="utf-8")

    if args.as_json:
        print(json.dumps(result, indent=2))
        return

    if args.markdown:
        print(markdown)
        return

    print("== Platform ==")
    print(f"System: {os_info['system']}")
    print(f"Release: {os_info['release']}")
    print(f"Machine: {os_info['machine']}")
    print(f"WSL: {'yes' if os_info['is_wsl'] else 'no'}")
    if os_info.get("distro"):
        print(f"Distro: {os_info['distro']}")
    if os_info.get("distro_like"):
        print(f"Distro-like: {os_info['distro_like']}")

    print("\n== Package managers ==")
    for name, present in managers.items():
        print(f"- {name}: {'yes' if present else 'no'}")
    print(f"Recommended package manager: {package_manager}")

    print("\n== Terminal tools ==")
    for _, data in terminal.items():
        status = "installed" if data["installed"] else "missing"
        command = f" ({data['command']})" if data.get("command") else ""
        version = f" | {data['version']}" if data.get("version") else ""
        print(f"- {data['label']}: {status}{command}{version}")

    print("\n== Agent tools ==")
    for key, data in agents.items():
        status = "installed" if data["installed"] else "missing"
        version = f" | {data['version']}" if data.get("version") else ""
        auth_state = auth[key]["status"]
        print(f"- {data['label']}: {status}{version} | auth: {auth_state}")

    print("\n== Package-manager install plan ==")
    for item in package_plan["installable"]:
        print(f"- {item['tool']}: package '{item['package']}'")
    if package_plan["manual"]:
        print("Manual or dedicated installers needed:")
        for item in package_plan["manual"]:
            print(f"- {item}")

    print("\n== Recommendations ==")
    for rec in recs:
        print(f"- {rec}")

    if args.plan_md:
        print(f"\nMarkdown plan written to: {args.plan_md}")


if __name__ == "__main__":
    main()
