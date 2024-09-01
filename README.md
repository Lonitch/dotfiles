# dotfiles for nvim/tmux/i3-based dev

<!-- mtoc-start -->

* [Intro](#intro)
* [Prerequisites](#prerequisites)
* [Cheat Sheet (`nvim` and `tmux`)](#cheat-sheet-nvim-and-tmux)

<!-- mtoc-end -->

## Intro

Managed by [GNU Stow](https://www.gnu.org/software/stow/), this repo gives configs for the following tools:

- `nvim` for Neovim(>0.9.4)
- `tmux` TMUX (>=3.3)
- `rust` for Rust dev(formatting)
- `zsh` for zsh(and oh-my-zsh)
- `kitty` for kitty terminal emulator
- `i3` for i3wm
- `picom` for stopping screen tearing
- `blueman` for bluetooth mgmt gui
- `bun` for running lint exec
- `node` for tree-sitter-cli
- `fcitx5` for dual input method
- `yazi` for previewer-enabled file explorer
- `utils` for shell scripts that improve life quality

To use config for anyone of the tools above, simply run the following:

```shell
stow <foldername>
```

>**Mod1** versus **Mod4**: The window key is **Mod1** on mac keyboard, change it to **Mod4** on win keyboard in `i3/.config/i3/config` as your command prefix in i3wm.

## Prerequisites

Other than the tools listed above, you may consider install the tools below as well:

- fuzzy search/preview: `fzf` and `bat`
- live text grep: `ripgrep`
- screenshot: `flameshot`, `maim`, `xclip`, and `copyq`
- [`rustfmt`](https://github.com/rust-lang/rustfmt)
- JS/TS runtime/pkg mgmt: `bun` (see [lsp config](./nvim/.config/nvim/lua/plugins/lsp-config.lua))
- JS/TS Linting: `eslint` and `vscode-langservers-extracted`
- Python Linting: [ `python-mode` ](https://github.com/python-mode/python-mode.git) and [ `pyright` ](https://github.com/microsoft/pyright) 
- Code-block report generator: [ `quarto` ](https://quarto.org) 
- MD to Presentation: [`marp-cli`](https://github.com/marp-team/marp-cli?tab=readme-ov-file#readme)
- Vim-like PDF viewer: [sioyek](https://sioyek-documentation.readthedocs.io/en/latest/)
- [ codelldb debugging ](<https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(via--codelldb)>)
  - you need to change the absolute path to `codelldb` in [debugging.lua](/lua/plugins/debugging.lua)

## Cheat Sheet (`nvim` and `tmux`)

<details><summary>Change Surrounds</summary>

| Old text                       | Command   | New text                   |
| :----------------------------- | :-------- | :------------------------- |
| surr\*ound_words               | ysiw      | (surround_words)           |
| \*make strings                 | ys$"      | "make strings"             |
| require"nvim-surroun\*d"       | ysa")     | require("nvim-surround")   |
| char c = \*x;                  | ysl'      | char c = 'x';              |
| int a[] = \*32;                | yst;}     | int a[] = {32};            |
| hel\*lo world                  | yss"      | "hello world"              |
| [delete ar*ound me!]           | ds]       | delete around me!          |
| remove \<b\>HTML t\*ags\<\/b\> | dst       | remove HTML tags           |
| 'change quot\*es'              | cs'"      | "change quotes"            |
| \<b\>or tag\* types\<\/b\>     | csth1<CR> | \<h1\>or tag types\<\/h1\> |
| delete(functi\*on calls)       | dsf       | function calls             |

</details>

<details><summary>Comments</summary>

- `<Ctrl-/>`: comment current line
- `<space>gf`: global formatting
- `[count]gcc`: Toggles the number of line given as a prefix-count using line wise
- `[count]gbc`: Toggles the number of line given as a prefix-count using block wise
- `gc`: toggle the selected region using linewise comment
- `gb`: toggle the selected region using blockwise comment

</details>

<details><summary>Debugging</summary>

- `<leader>od`: "open debug ui"
- `<leader>cd`: "close debug ui"
- `<leader>tb`: "toggle breakpoint"
- `<leader>=`: "start debugger/continue"
- `<leader>-`: "step over debugger"
- `<space><space>f`: open floating msg from LSP at current line

</details>

<details><summary>Find things</summary>

- `<space>h`: remove search highlights
- `<space>n`: open/close neotree file system, use `f`/`b`/`g`/`c` to open filesystem/buffers/git/components tabs
- `<space>ff`: open telescope file finder
- `<space>lg`: open telescope live grep
- `<space>bo`: show all opened buffers
- `<Ctrl-q>`: save live-grep results from telescope to a split window at the bottom

</details>

<details><summary>Fold Codes</summary>

- `zo/c`: open/close fold under the cursor
- `zO/C`: open/close fold recursively under the cursor, folds without cursor in them unaffected
- `zR`: open all folds
- `zM`: close all folds

</details>

<details><summary>fzf</summary>

- `inv`: open a file interactively in neovim
- `<leader>wd`: set pwd to the path where opened buffer is located in neovim
- `cd [pattern]**<tab>`: trigger fzf for goint to a folder.(folder starts with dot is not listed)

</details>

<details><summary>Git</summary>

`git-fugitive` and `vim-flog` are currently added to run git commands in nvim. You can use `:Git` to run commands just like you do in terminal. Some examples are:

- `<leader>gp`: preview the hunk of current line
- `:Git add`: `git add` in terminal
- `:Git commit`: `git commit` in terminal

Use `:Flog` to open a new tab that shows results of `git log`. The new tab contains info of all commits. You can find out what this command can do by `:help Flog`. Here we recommend 3 use cases:

- Checking out a branch:

  - use `:Flog` to open new tab that shows all the commits
  - hit "a" to show all hidden commits
  - navigate to the branch you desire
  - use `cob` to checkout the branch

- View history of selected lines of code

  - in visual mode, select lines of code of your interest
  - use `:Flog` to open a new tab to show the past history relevant only to the selected snippet

- View history of specific file

```bash
:Flog -path=path/to/file
```

</details>

<details><summary>Go to places</summary>

- `g;`: go to last changed place
- `gi`: go to last place and insert
- `<space><space>b`: go to next opened buffer
- `<space>bb`: go to previous opened buffer
- `gt`: go to the last tab
- `<space>j`: jump to the bottom line and centers the window at the line(page-down)
- `<space>m`: jump to the top line and centers the window(page-up)
- `<space>gd`: go to definition

</details>

<details><summary>Markdown</summary>

- `:Mtoc i`: insert ToC
- `:Mtoc u`: update ToC
- `:Mtoc r`: remove ToC
- `:Tab/x`: align this paragraph based on `x`

</details>

<details><summary>Mode Switch</summary>

- `<Alt-f>`: escape insert mode and jump out of current paired ""/[]/{}/()/''/,/``

</details>

<details><summary>neo-tree</summary>

In `neotree`:

- `a`: add file/folder
- `d`: delete file/folder
- `r`: rename

</details>

<details><summary>Programming Hints</summary>

- `<space>k`: see function info
- `<space>gd`: go to definition
- `<space>a`: see code actions
</details>

<details><summary>Python-mode</summary>

We use `rope` in `python-mode` for `goto_definition` functionality.

- `:PymodeLintAuto`: auto-fix PEP8 issues
- `<C-Space>` in `.py`: auto-completion
- `:QuartoPreview`: preview quarto file

</details>

<details><summary>Tabs and Windows</summary>

- `<A-h/j/k/l>`: switch windows of tmux and neovim interchangeably
- `<space>-<Tab>`: use this keybinding to jump to LSP windows
- `tabe .`: create a new tab

In `telescope`(either `<leader>ff`, or `<leader>lg`), you can

- `<C-x>`: Go to file selection as a split
- `<C-v>`: Go to file selection as a vsplit

</details>

<details><summary>Terminal</summary>

- `:terminal`: open a terminal in neovim as a split window
- `i/I/a/A`: insert in terminal window
- `<C-\><C-O>`: exit typing mode

</details>

<details>
<summary><b>tmux Configuration</b></summary>

- To make pane behaves like normal terminal, `shift` should be hold. For example, to paste stuff from clipboard in `tmux` terminal pane, you need `shift+right click`.
- enter copy mode: `<C-a>-[`
- move around using `h/j/k/l/0/$`
- begin copy highlighting: `<space>` or `v`
- copy: `<CR>` or `y`
- paste with `<C-a>+]`
- exit copy mode: `<C-c>`
- Simple workflow with `tmux`

  ```bash
  # in terminal, create a new session
  tmux new -s sessionName
  # detach from a session
  tmux detach
  # attach to a session
  tmux attach -t sessionName
  # kill a session/window
  tmux kill-session -t sessionName
  # if you have pre-stored session, simply run
  tmux

  # create a horizontal pane using <C-a>+-
  # adjust the height of the two panes using j/k
  # switch between panes using <C-a>+↑/↓
  # close pane by typing 'exit'
  # open neovim in upper pane, run terminal cmd in lower pane

  # for full-stack dev., it's useful to create 2 windows in a session
  # create a new window: <C-a>+c
  # switch between windows: <C-a>+w
  # <C-a>+c to create new window
  ```

</details>

<details><summary>Workspace</summary>

A workspace is a folder containing multiple git repositories. Here we use [`projections.nvim`](https://github.com/GnikDroy/projections.nvim/tree/pre_release?tab=readme-ov-file) to manage workspaces. Using it gives you the following options:

- `:AddWorkspace` to register current folder as a workspace
- `<leader>fp` to list all the projects in current workspace
- automatically save current `neovim` session. Next time when you are at a project folder, the latest session is restored.

</details>
