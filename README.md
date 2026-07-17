# configs

Snapshot of my laptop + devbox config, for reference and easy re-setup on a new
machine. These are **copies** — editing a file here does not change the live
config. To apply, copy the file back to its destination (paths listed below).

## Layout

| Path | Lives at | What it is |
|------|----------|------------|
| `shell/zshrc` | `~/.zshrc` | Local (laptop) zsh config |
| `shell/bashrc` | `~/.bashrc` | Local bash (rarely used on laptop) |
| `shell/zprofile` | `~/.zprofile` | brew shellenv + OrbStack init |
| `shell/profile` | `~/.profile` | cargo env |
| `shell/devbox.bashrc` | appended to `~/.bashrc` on devbox | Devbox overlay (append, don't replace) |
| `ghostty/config` | `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` | Ghostty terminal |
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

### Shell — devbox (`devbox.bashrc`, bash on devbox)
Remote runs **bash**, not zsh. This file is **not** a full `~/.bashrc` — it's a
non-destructive overlay meant to be **appended** on top of the devbox's existing
bashrc. Everything else the box need comes from the default bashrc and is deliberately not tracked here.
The only things carried over from local are:

- `set -o vi` — vi mode parity.
- Same prompt idea (cwd in **green** `38;5;34` here vs orange locally) + venv.
- `yolo` → `claude --dangerously-skip-permissions`.

Apply with: `cat shell/devbox.bashrc >> ~/.bashrc` on devbox

### Ghostty (`ghostty/config`)
- `cmd+e` → `close_surface` (close focused split/tab/window, like typing `exit`).
  The Cursor `cmd+e` / `cmd+d` / `cmd+[` / `cmd+]` bindings mirror this and
  Ghostty's default split navigation.
- `confirm-close-surface = false` — no prompt when closing a surface with a
  running process.

### Karabiner
- One mapping only: **caps_lock → escape**. ANSI keyboard.

### macOS key repeat (`macos/keyboard.sh`)
- `KeyRepeat=2`, `InitialKeyRepeat=15` (fastest the UI allows).
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
- `gb` → `<C-o>` (jump back).
- **`{` and `}` swapped** in normal + visual mode (paragraph motions inverted to match ghostty window management)

### Zed
Zed has its own **native** vim mode — it does **not** read Cursor/VSCode's
`settings.json` or the VSCodeVim extension config. Remaps must be redone in
Zed's own `keymap.json`.

**Keymap** (`zed/keymap.json`):
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
