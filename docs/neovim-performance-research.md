# Neovim performance and plugin-freshness screen

_Checked 2026-08-31 against Neovim 0.12.5, the initial and optimized configs,
their `lazy-lock.json`, and first-party Neovim/plugin documentation._

## Result

The pass implemented simplifications rather than wholesale plugin replacements:

1. Replaced `Comment.nvim` with Neovim's built-in `gc` commenting, while
   retaining
   `nvim-ts-context-commentstring` through its native Neovim integration for
   correct JSX comments.
2. Replaced a source-less `nvim-cmp`/LuaSnip stack with Neovim's native LSP
   completion and snippet support.
3. Made `nvim-web-devicons` lazy and deferred Conform until first format/save.
4. Removed the unused, 2023-era `telescope-media-files.nvim` extension.
5. Removed redundant `nvim-lint` subprocesses and replaced `vim-illuminate`
   with native LSP document highlights.
6. Restored Gitsigns' cheaper untracked-file default and removed its stale
   `watch_gitdir.interval` option.

Twelve separate headless runs were collected for each path; medians are used
because startup had occasional OS/filesystem outliers.

| Path | Initial median | Optimized median | Change |
| --- | ---: | ---: | ---: |
| Empty startup | 40.812 ms | 39.744 ms | -2.6% |
| Open `lua/lk/plugins.lua` | 135.811 ms | 102.778 ms | -24.3% |
| Dispatch first `InsertEnter` | 16.680 ms | 2.328 ms | -86.0% |
| Load Telescope and dependencies | 12.103 ms | 7.734 ms | -36.1% |

Loaded plugins fell from 6 to 5 for an empty headless startup and from 18 to
12 for a representative TypeScript file after LSP attachment.

The largest remaining fixed plugin cost is the Vitesse/Colorbuddy theme path.
On file startup, Gitsigns and Mason/LSP setup are the next substantial groups.
Changing the theme would alter the UI, while removing Git signs or delaying LSP
would trade away editing behavior, so this pass leaves them intact.

Oil and nvim-treesitter should stay eager: both projects explicitly say that
lazy-loading is unsupported or not recommended. The remaining visual plugins
should only be removed or reconfigured after measuring editing/redraw latency;
their repositories are current and upstream provides no evidence that a
replacement is inherently faster.

## What must be measured locally

Upstream maintenance and architecture do not prove a local speedup. Establish
before/after distributions for:

- empty startup and startup opening a representative TypeScript file, using
  `nvim --startuptime <file>` over multiple warm runs;
- the first `InsertEnter`, first Telescope picker, and first Git-tracked file;
- typing/cursor/redraw responsiveness in a representative large file.

Neovim documents `--startuptime` as the tool for locating slow startup work,
and lazy.nvim provides `:Lazy profile`, including the reason each plugin was
loaded. Sources: [Neovim startup documentation], [lazy.nvim profiling].

A headless inspection of the initial config's loaded Lazy state (not a duration
benchmark) found these plugins loaded on an empty startup:
`lazy.nvim`, `vitesse.nvim`, `colorbuddy.nvim`, `oil.nvim`, `nvim-treesitter`,
and `nvim-web-devicons`.

## High-confidence changes

### 1. Use built-in commenting with contextual comment strings

Neovim has provided `gc{motion}`, `gcc`, and visual `gc` since 0.10. On the
installed 0.12.5, built-in commenting looks up `commentstring` at the cursor
through Tree-sitter, including injected languages; Tree-sitter highlight
queries can also set finer-grained `bo.commentstring` metadata. Sources:
[Neovim commenting], [Neovim Tree-sitter comment strings].

That native metadata was not sufficient for this exact setup: a local TSX
fixture commented JSX text as `// hello` without the context plugin, rather
than `{/* hello */}`. Retain `nvim-ts-context-commentstring`, disable its
`CursorHold` autocmd, and use its documented native Neovim integration so the
calculation runs only when `commentstring` is requested. This removes
`Comment.nvim` and the context plugin's idle-time work while preserving JSX
behavior. Source: [nvim-ts-context-commentstring native integration].

Acceptance check: JSX/Vue/Svelte embedded comments must still use the right
delimiter. Native commenting does not provide all Comment.nvim extras, notably
the `gb` block-comment family and `gcO`/`gco`/`gcA`; confirm those are not part
of the workflow before removal.

Freshness is not the main argument: `nvim-ts-context-commentstring` is current
(installed commit from 2026-04-04), while the installed Comment.nvim revision's
last commit is from 2024-06-09. The built-in path is preferable because the
configuration's required behavior is now native. Sources: [context-commentstring
installed commit], [Comment.nvim installed commit].

### 2. Remove or complete the unused completion stack

`nvim-cmp` is maintained: the installed revision is a 2026-07-10 bug fix. It is
not a stale plugin. However, its upstream defaults specify `sources = {}`, and
the initial config never overrode `sources`. `cmp-nvim-lsp` was used only to
advertise capabilities, while nvim-cmp and LuaSnip loaded on `InsertEnter`; the
autopairs configuration also eagerly required `cmp`. Sources: [nvim-cmp
installed commit], [nvim-cmp default configuration].

For this deliberately small config, the simplest completion path is Neovim's
built-in LSP completion plus native `vim.snippet`. Neovim 0.12 documents
`vim.lsp.completion.enable()` with optional `autotrigger = true` and
`vim.lsp.completion.get()` for a manual mapping. This can remove `nvim-cmp`,
`cmp-nvim-lsp`, and LuaSnip, plus the cmp-specific nvim-autopairs hook. Source:
[Neovim LSP completion].

If buffer/path sources, advanced ranking, or a richer UI are desired, keep and
correct nvim-cmp or benchmark `blink.cmp`. Blink advertises 0.5-4 ms async
updates and supports LSP, buffer, snippet, and path sources, but this is the
project's own benchmark and not evidence of a gain in this config. Its 1.10.0
changelog also says that release is the final 1.x before 2.0, so migration now
has some near-term churn risk. Sources: [blink.cmp], [blink.cmp 1.10 changelog].

### 3. Lazy-load devicons

The standalone `"nvim-tree/nvim-web-devicons"` spec has no lazy trigger, and
lazy.nvim's default is `lazy = false`; it therefore loads at empty startup.
lazy.nvim's own example specifically configures devicons with `lazy = true`
because requiring its module will load it on demand. Oil and lualine can then
trigger it when they actually need icons. Sources: [lazy.nvim lazy-loading],
[lazy.nvim devicons example].

This is a low-risk startup change, but its actual millisecond gain still needs
the startup benchmark.

### 4. Remove or defer Telescope media files

Telescope itself is current, command/key lazy-loaded, and should not affect
empty startup. Its installed revision dates to 2026-06-23. The media-files
extension is much older: its installed locked revision dates to
2023-02-19, and its README still describes a separate media toolchain. The
initial config had no media-files key mapping but called
`load_extension('media_files')` whenever Telescope first opened. Sources:
[Telescope installed commit],
[media-files installed commit], [media-files README].

If media previews are unused, remove the extension. If they are used, Telescope
says explicit extension loading can be omitted and the extension will then be
loaded on demand (at the cost of immediate command-line tab completion).
Source: [Telescope extension loading].

For slow sorting over large result sets, Telescope strongly recommends a
native sorter such as `telescope-fzf-native.nvim`. This affects picker
interaction, not empty startup, and adds a native build dependency, so only add
it when the first-picker benchmark demonstrates a problem. Sources: [Telescope
recommended dependencies], [telescope-fzf-native].

### 5. Use Gitsigns' cheaper untracked-file default

Gitsigns is current and already has sensible performance controls here:
current-line blame and word diff are off, updates are debounced, and files over
40,000 lines are excluded. The installed revision dates to 2026-07-14, and its
2026 changelog includes deferring hidden-buffer updates. Sources: [Gitsigns
installed commit], [Gitsigns changelog].

The config overrides `attach_to_untracked = true`, whereas current Gitsigns
defaults it to `false`. Restore the default unless signs in new/untracked files
are valuable, then benchmark first-file time in a large repository. The nested
`watch_gitdir.interval = 1000` field is no longer documented; current
`watch_gitdir` only has `enable` and `follow_files`, so remove the stale no-op
setting during cleanup. Source: [Gitsigns configuration].

## Measure-first candidates

### Hop

Hop is already key-lazy, so it adds no empty-startup cost. The installed
smoka7 fork has not changed since 2024-10-17, while `flash.nvim` and
`leap.nvim` are active alternatives; Flash directly supports labeled
`f`/`t`/`F`/`T` motions. Sources: [Hop installed commit], [Flash features],
[Leap repository].

Do not claim a performance win from replacing Hop: the cost occurs only on the
first mapped motion, and none of these first-party sources provides a
like-for-like local benchmark. Native `f`/`t` has zero plugin cost but removes
labels. Choose Flash for maintained functionality, or native motions for
minimalism, not on an unmeasured speed claim.

### vim-illuminate

vim-illuminate is current (installed commit 2026-07-11) and already disables
itself above 10,000 lines. It does, however, listen to cursor/text changes and
uses LSP with a regex fallback, making it a steady-state candidate rather than
an empty-startup issue. Sources: [vim-illuminate installed commit],
[vim-illuminate configuration].

If LSP-only highlighting is sufficient, Neovim documents the smaller native
combination: `vim.lsp.buf.document_highlight()` on `CursorHold` and
`vim.lsp.buf.clear_references()` on `CursorMoved`. This loses regex highlighting
in buffers without a capable LSP, so only replace after checking that behavior.
Source: [Neovim document highlights].

### indent-blankline and treesitter-context

Both projects are current (installed commits from 2026-02-17 and 2026-05-06).
They load on the first buffer rather than empty startup, and both perform work
as the cursor/window changes. indent-blankline's scope feature requires
Tree-sitter; treesitter-context throttles updates and documents that
`max_lines = 0` means no display limit. Sources: [indent-blankline installed
commit], [indent-blankline scope], [treesitter-context installed commit],
[treesitter-context configuration].

Only tune these if the large-file/redraw benchmark points to them. The first
reversible reductions are disabling indent-blankline scope or enabling context
only where wanted. Built-in `listchars` can replace simple indent glyphs, but it
does not replace syntax-aware scope/context behavior.

### Oil and nvim-treesitter

Do not lazy-load these as a generic optimization. Oil says lazy-loading is not
recommended because correctly replacing the default file explorer is tricky.
nvim-treesitter's current `main` rewrite explicitly says it does not support
lazy-loading and recommends `lazy = false`; `install(languages)` is asynchronous
and a no-op for already-installed parsers. Sources: [Oil installation],
[nvim-treesitter installation].

Both installed revisions are current (Oil 2026-06-02, nvim-treesitter
2026-07-26). Keep the eager declarations unless a measured problem justifies a
larger behavioral redesign. Sources: [Oil installed commit], [nvim-treesitter
installed commit].

## Suggested implementation order

1. Capture the startup, first-file, first-insert, and first-picker baselines.
2. Make devicons lazy; remove/defer media-files if unused; remeasure startup and
   first picker.
3. Migrate to native commenting with the context-commentstring integration and
   raise `updatetime` from 50 ms if no other feature needs it; verify
   injected-language comments.
4. Replace the source-less cmp stack with built-in LSP completion, or explicitly
   configure the desired cmp sources; verify snippets and completion UX.
5. Restore Gitsigns' untracked default; measure large-repository file opening.
6. A/B test illuminate, indent-blankline scope, and treesitter-context only if
   editing/redraw measurements remain slow.
7. Treat Hop-to-Flash and Telescope-to-another-picker migrations as product/UX
   decisions, not default performance work.

[Neovim startup documentation]: https://neovim.io/doc/user/starting/#--startuptime
[lazy.nvim profiling]: https://lazy.folke.io/usage/profiling
[Neovim commenting]: https://neovim.io/doc/user/various/#commenting
[Neovim Tree-sitter comment strings]: https://neovim.io/doc/user/treesitter/#treesitter-highlight-commentstring
[nvim-ts-context-commentstring configuration]: https://github.com/JoosepAlviste/nvim-ts-context-commentstring#configuration
[nvim-ts-context-commentstring native integration]: https://github.com/JoosepAlviste/nvim-ts-context-commentstring/wiki/Integrations#native-commenting-in-neovim-010
[context-commentstring installed commit]: https://github.com/JoosepAlviste/nvim-ts-context-commentstring/commit/6141a40173c6efa98242dc951ed4b6f892c97027
[Comment.nvim installed commit]: https://github.com/numToStr/Comment.nvim/commit/e30b7f2008e52442154b66f7c519bfd2f1e32acb
[nvim-cmp installed commit]: https://github.com/hrsh7th/nvim-cmp/commit/2ffe79f1f021def8dd1fcd81deb16f1bb0d989f3
[nvim-cmp default configuration]: https://github.com/hrsh7th/nvim-cmp/blob/2ffe79f1f021def8dd1fcd81deb16f1bb0d989f3/lua/cmp/config/default.lua#L83
[Neovim LSP completion]: https://neovim.io/doc/user/lsp/#lsp-completion
[blink.cmp]: https://github.com/Saghen/blink.cmp
[blink.cmp 1.10 changelog]: https://github.com/Saghen/blink.cmp/blob/main/CHANGELOG.md#1100-2026-03-14
[lazy.nvim lazy-loading]: https://lazy.folke.io/spec/lazy_loading
[lazy.nvim devicons example]: https://github.com/folke/lazy.nvim/blob/main/lua/lazy/example.lua
[Telescope installed commit]: https://github.com/nvim-telescope/telescope.nvim/commit/427b576c16792edad01a92b89721d923c19ad60f
[media-files installed commit]: https://github.com/nvim-telescope/telescope-media-files.nvim/commit/0826c7a730bc4d36068f7c85cf4c5b3fd9fb570a
[media-files README]: https://github.com/nvim-telescope/telescope-media-files.nvim
[Telescope extension loading]: https://github.com/nvim-telescope/telescope.nvim#loading-extensions
[Telescope recommended dependencies]: https://github.com/nvim-telescope/telescope.nvim#recommended-dependencies
[telescope-fzf-native]: https://github.com/nvim-telescope/telescope-fzf-native.nvim
[Gitsigns installed commit]: https://github.com/lewis6991/gitsigns.nvim/commit/31d6fb2d618bca1482b9f274751ead5f03461408
[Gitsigns changelog]: https://github.com/lewis6991/gitsigns.nvim/blob/main/CHANGELOG.md#210-2026-03-26
[Gitsigns configuration]: https://github.com/lewis6991/gitsigns.nvim/blob/main/doc/gitsigns.txt
[Hop installed commit]: https://github.com/smoka7/hop.nvim/commit/08ddca799089ab96a6d1763db0b8adc5320bf050
[Flash features]: https://github.com/folke/flash.nvim
[Leap repository]: https://github.com/ggandor/leap.nvim
[vim-illuminate installed commit]: https://github.com/RRethy/vim-illuminate/commit/91313e598ca62e110bc71535c49069b66b9883c9
[vim-illuminate configuration]: https://github.com/RRethy/vim-illuminate#configuration
[Neovim document highlights]: https://neovim.io/doc/user/lsp/#vim.lsp.buf.document_highlight()
[indent-blankline installed commit]: https://github.com/lukas-reineke/indent-blankline.nvim/commit/d28a3f70721c79e3c5f6693057ae929f3d9c0a03
[indent-blankline scope]: https://github.com/lukas-reineke/indent-blankline.nvim#scope
[treesitter-context installed commit]: https://github.com/nvim-treesitter/nvim-treesitter-context/commit/b311b30818951d01f7b4bf650521b868b3fece16
[treesitter-context configuration]: https://github.com/nvim-treesitter/nvim-treesitter-context#configuration
[Oil installation]: https://github.com/stevearc/oil.nvim#installation
[nvim-treesitter installation]: https://github.com/nvim-treesitter/nvim-treesitter#installation
[Oil installed commit]: https://github.com/stevearc/oil.nvim/commit/b73018b75affd13fa38e2fc94ef753b465f770d7
[nvim-treesitter installed commit]: https://github.com/nvim-treesitter/nvim-treesitter/commit/61df84986b4b4ec469ee745a182e433d49f8c27e
