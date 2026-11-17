# configs

Personal dotfiles for my typing, keyboard, shell, editor, and terminal
experience, shared between my Mac and remote development shells. These are
**copies** — editing a file here does not change the live config. To apply,
copy the file back to its destination (paths listed below).

## Layout

| Path | Lives at | What it is |
|------|----------|------------|
| `shell/zshrc` | `~/.zshrc` | Local (laptop) zsh config |
| `shell/bashrc` | `~/.bashrc` | Local bash (rarely used on laptop) |
| `shell/zprofile` | `~/.zprofile` | brew shellenv + OrbStack init |
| `shell/profile` | `~/.profile` | cargo env |
| `shell/devbox.bashrc` | appended to `~/.bashrc` on devbox | Devbox overlay (append, don't replace) |
| `atuin/config.toml` | `~/.config/atuin/config.toml` | Shared history-search preferences |
| `ghostty/config` | `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` | Ghostty terminal |
| `ghostty/shaders/` | `~/.config/ghostty/shaders/` | Cursor shaders (Mac + devbox) |
| `ghostty/ghostty-tmux` | `~/.local/bin/ghostty-tmux` (executable) | Local tmux launcher for Ghostty |
| `tmux/tmux.conf` | `~/.tmux.conf` locally; `~/.config/tmux/ghostty.conf` on devbox | Pane shortcuts, mouse, clipboard, and appearance |
| `tmux/remote.conf` | `~/.config/tmux/ghostty-remote.conf` on devbox | Remote navigation bindings and green dividers |
| `ghostty/ghostty-tmux-ssh` | `~/.local/bin/ghostty-tmux-ssh` (Mac, executable) | SSH with pane shortcut forwarding |
| `ghostty/ghostty-tmux-remote` | `~/.local/bin/ghostty-tmux-remote` (devbox, executable) | Attach to the shared remote workspace |
| `ghostty/tmux.zsh` | `~/.config/ghostty/tmux.zsh` (Mac) | Route plain `ssh modal-dev` into the workspace |
| `karabiner/karabiner.json` | `~/.config/karabiner/karabiner.json` | Karabiner-Elements |
| `cursor/keybindings.json` | `~/Library/Application Support/Cursor/User/keybindings.json` | Cursor keybindings |
| `cursor/settings.json` | `~/Library/Application Support/Cursor/User/settings.json` | Cursor settings (incl. vim mode) |
| `zed/keymap.json` | `~/.config/zed/keymap.json` | Zed keymap (vim `{`/`}` swap) |
| `macos/keyboard.sh` | run once | Key-repeat + press-and-hold defaults |

---

## Non-standard decisions (the stuff worth remembering)

### Shell — local (`zshrc`, zsh)
- **Vi mode** everywhere: `bindkey -v`.
- **Custom prompt**: leading blank line, venv name, then cwd in orange
  (`%F{214}`). `VIRTUAL_ENV_DISABLE_PROMPT=1` because the prompt renders the
  venv itself.
- **Aliases**:
  - `yolo` → `claude --dangerously-skip-permissions`
  - `code` → **opens Zed**, not VSCode.
- Atuin history search is initialized in zsh and the fallback bash shell.

### Shell — devbox (`devbox.bashrc`, bash on devbox)
Remote runs **bash**, not zsh. This file is **not** a full `~/.bashrc` — it's a
non-destructive overlay meant to be **appended** on top of the devbox's existing
bashrc. Everything else the box need comes from the default bashrc and is deliberately not tracked here.
The only things carried over from local are:

- `set -o vi` — vi mode parity.
- Same prompt idea (cwd in **green** `38;5;34` here vs orange locally) + venv.
- `yolo` → `claude --dangerously-skip-permissions`.
- Atuin history search, when installed.

Apply with: `cat shell/devbox.bashrc >> ~/.bashrc` on devbox

### Atuin (`atuin/config.toml`)
These explicit settings match the live Mac and `modal-dev` configs:
- `search_mode = "daemon-fuzzy"`.
- `enter_accept = true` — Enter executes the selected command.
- `[daemon] enabled = true`, `autostart = true`.

Install Atuin into `~/.atuin/bin`, then copy this file to
`~/.config/atuin/config.toml`. Shell startup sources `~/.atuin/bin/env` and
initializes the appropriate shell integration. Import existing shell history
once with `atuin import auto`. Sync login, encryption keys, history databases,
and machine-specific paths are not stored in this repo. Mise is deliberately
not part of this snapshot.

### Ghostty + tmux (`ghostty/config`, `tmux/tmux.conf`)
Ghostty displays local tmux; an SSH pane can display a shared remote tmux
workspace inside it. Cmd shortcuts act on the current local or remote workspace:

| Shortcut | Action |
|----------|--------|
| `cmd+d` | Split left/right, inheriting the active pane's working directory |
| `cmd+shift+d` | Split top/bottom, inheriting the active pane's working directory |
| `cmd+e` | Kill the focused pane, including its running process |
| `cmd+[` / `cmd+]` | Cycle all panes, crossing between remote workspaces and local panes |
| `cmd+shift+e` | Detach from the remote workspace (or local session if already local) |

- Each native Ghostty tab/window launches `~/.local/bin/ghostty-tmux`.
  It restores the most recently attached, currently detached local session,
  or creates a fresh one. `cmd+t` / `cmd+w` still open/close native tabs.
  Closing a native tab detaches local tmux; closing the last tmux pane ends
  its session and closes that tab.
- In a local tmux pane, plain **`ssh modal-dev`** runs the remote launcher.
  It joins the shared **`devbox`** session on the remote `ghostty` tmux server.
  Cmd shortcuts are forwarded to that session while SSH is running. Remote
  splits occupy the original local pane's area; they are not local panes.
- `cmd+]` advances through remote panes, then leaves the last remote pane
  for the next local pane. `cmd+[` leaves the first remote pane for the
  previous local pane. Entering a remote workspace selects its first pane
  when moving forward, or its last pane when moving backward. With only one
  local pane, cycling wraps within the remote workspace. Remote tmux sends
  boundary flags in its terminal title over the existing connection; local
  tmux hides these flags from the visible title. Native bindings use the
  cached flags, with no per-key shell process or additional SSH request.
- If SSH drops, the remote layout and processes keep running. The original
  local shell returns after SSH detects the disconnect (10-second keepalives,
  three missed replies). Cmd shortcuts now operate locally again. Running
  `ssh modal-dev` restores the complete remote workspace. `cmd+shift+e`
  returns locally immediately while preserving remote work. Typing `exit`
  closes the active remote shell; exiting its last pane ends that workspace.
- Two local panes running `ssh modal-dev` attach to the **same** remote layout,
  processes, and active pane. Both can type into it. The remote window fits
  the smallest attached client. Detaching either client leaves the other
  connected. Local and remote session persistence lasts until their host
  reboots or the session's panes are explicitly closed.
- The SSH wrapper is installed after Ghostty's deferred shell integration.
  It only changes plain `ssh modal-dev` in a local `ghostty` tmux server.
  SSH commands with extra arguments, other hosts, and noninteractive SSH
  keep their normal behavior. No global SSH or devbox shell startup changes
  are needed.
- Active local dividers use orange `colour214`; remote dividers use green
  `colour34`, matching their respective cwd prompts.
- Pane backgrounds always indicate location, with a 4% tint when unfocused
  and 8% when focused: orange `#28251e` / `#312b1d` locally, green
  `#1e251e` / `#1d2b1d` remotely. These are preblended over Dark Modern's
  `#1f1f1f` background because tmux pane styles have no alpha.
  Focus hooks dim the remote tint when a local pane takes focus.
  Applications that paint an explicit background can cover the tint.
- Status bars are hidden. Mouse support enables click-to-focus, dragging
  dividers, and scrolling history. Mouse-drag selections copy through OSC 52,
  including from remote tmux; hold Shift to select with Ghostty itself.
  The mouse can also select any visible local or remote pane directly.

Setup on the Mac: `brew install tmux`; copy `tmux/tmux.conf` to `~/.tmux.conf`,
`ghostty/ghostty-tmux` and `ghostty/ghostty-tmux-ssh` to `~/.local/bin/` (make
both executable), and copy `ghostty/tmux.zsh` to `~/.config/ghostty/tmux.zsh`.
Apply `ghostty/config` and the integration/source blocks from `shell/zshrc`.
On the devbox, install tmux, copy `tmux/tmux.conf` to
`~/.config/tmux/ghostty.conf`, `tmux/remote.conf` to
`~/.config/tmux/ghostty-remote.conf`, and `ghostty/ghostty-tmux-remote` to
`~/.local/bin/ghostty-tmux-remote` (make it executable).

Both launchers use `tmux -L ghostty` so unrelated tmux servers/sessions are
left alone. Reload local tmux with `tmux -L ghostty source-file ~/.tmux.conf`;
reload remote tmux with
`ssh modal-dev 'tmux -L ghostty source-file ~/.config/tmux/ghostty-remote.conf'`.
Reload Ghostty with `cmd+shift+,`. Existing native splits/shells aren't moved
into tmux: use a new native tab/window, or run `~/.local/bin/ghostty-tmux`
from an existing local shell. New shells load the SSH wrapper automatically.

- `confirm-close-surface = false` — no prompt when closing a surface with a
  running process.
- `custom-shader = ~/.config/ghostty/shaders/cursor-trail.glsl` enables the
  cursor trail used by [jcmorrow/dotfiles](https://github.com/jcmorrow/dotfiles/tree/main/config/ghostty/shaders).
  All three shaders are copied from commit
  `a7328b7a8b9108e831020f7a2b98c6210e04a677`; the two blaze variants are
  alternatives, enabled by changing the filename (use one at a time).
  Copy the shader directory along with the config when setting up a new Mac.
  Reload Ghostty with `cmd+shift+,` after applying changes.
  The Mac renders the effect for local shells and SSH sessions alike.
  Shader files and a shader-only `~/.config/ghostty/config` are also installed
  on `modal-dev` for use if Ghostty is installed there; the devbox currently
  has no Ghostty executable.

### Karabiner
- One mapping only: **caps_lock → escape**. ANSI keyboard.

### macOS key repeat (`macos/keyboard.sh`)
- `KeyRepeat=2.5`, `InitialKeyRepeat=15` (fastest the UI allows).
- `ApplePressAndHold` is **currently unset** on the machine. The script sets it
  to `false` to force true key-repeat over the accent popup — relevant for the
  **built-in** keyboard. The Oryx/ZSA external board does repeat in firmware, so
  its behavior is independent of these macOS settings (that's the "workaround":
  configure repeat in Oryx for the external board, and these defaults for the
  laptop keyboard).

### Cursor
Cursor is the editor in use — stock VSCode (`~/Library/.../Code/User/`) is empty.

**Keybindings** (`cursor/keybindings.json`):
- `shift+k` → hover (vim normal mode only) — mimics nvim `K`.
- `cmd+f` → unbound from find.

The below are intended to mirror ghostty window management
- `cmd+d` → move editor to right group.
- `cmd+[` / `cmd+]` → focus left / right editor group.
- `cmd+e` → close group.

**Vim mode** (`cursor/settings.json`):
- `+` → `#` (backward word search); `#` is disabled.
- `gb` → `<C-o>` (jump back).
- **`{` and `}` swapped** in normal + visual mode (paragraph motions inverted to match ghostty window management)

### Zed
Zed has its own **native** vim mode — it does **not** read Cursor/VSCode's
`settings.json` or the VSCodeVim extension config. Remaps must be redone in
Zed's own `keymap.json`.

**Keymap** (`zed/keymap.json`):
- `g b` → `pane::GoBack`, matching Cursor; the keymap also unbinds `ctrl-o`.
- `+` → `vim::MoveToPrevious` (backward word search); `#` is disabled.
- **`{` and `}` swapped** (`{` → `vim::EndOfParagraph`, `}` →
  `vim::StartOfParagraph`) so paragraph motions match the physical layout
  (`{` on `j` = down, `}` on `k` = up). Same intent as the Cursor swap above,
  but under the `VimControl && !menu` context, which covers normal + visual +
  operator-pending in one block.
- **Split management** (mirrors Cursor / Ghostty), bound in `Editor` context to
  override Zed's defaults:
  - `cmd-d` → `workspace::MoveItemToPaneInDirection` — **moves** (not clones) the
    current file into a split on the right, creating the split if needed
    (defaults: direction Right, `clone: false`).
  - `cmd-[` / `cmd-]` → `workspace::ActivatePaneLeft` / `ActivatePaneRight`
    (move focus between splits)
  - `cmd-e` → `pane::CloseAllItems` — closes the current split (all its tabs),
    like Ghostty `close_surface` / Cursor `closeGroup`.
  - `cmd-(` / `cmd-)` tab navigation is left as-is (matches Chrome behavior).
