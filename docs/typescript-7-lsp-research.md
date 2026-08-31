# TypeScript 7 LSP in Neovim

_Checked 2026-08-31 against TypeScript 7.0.2 and nvim-lspconfig commit
`16286347bdba1333c7d124d9de9fe6630731b2b2`._

## Conclusion

This upgrade is possible and is now the first-party nvim-lspconfig path. Use the
server configuration name `tsc`, backed by the stable `typescript` npm package,
and enable it with:

```lua
vim.lsp.enable("tsc")
```

nvim-lspconfig added `tsc` on 2026-08-12 and fixed its TypeScript-version
selection on 2026-08-17. The older `tsgo` configuration is now only a deprecated
alias for `tsc`. New configurations should not use `tsgo` or the preview package
`@typescript/native-preview`.

Sources: [nvim-lspconfig `tsc` documentation], [the introducing commit],
[the version-selection fix], [deprecated `tsgo` alias].

## Package and command

- Install stable TypeScript 7 in each project with `npm install -D typescript`.
  This supplies `node_modules/.bin/tsc`; as of the check date, npm's stable
  release is `typescript@7.0.2`. A global `npm install -g typescript@7` is also a
  viable PATH fallback for projects that do not install TypeScript 7 locally.
- In this Mason-based Neovim config, use the Mason package/server name `tsc` in
  `ensure_installed`. The current Mason registry installs
  `typescript@7.0.2`, exposes its `tsc` executable, and maps it directly to the
  nvim-lspconfig name `tsc`. Mason deprecated its `tsgo` package on 2026-08-13.
- The language server command is `tsc --lsp --stdio`. `--lsp` exists only in
  native TypeScript 7 and newer.
- `@typescript/native-preview` supplies the old `tsgo` binary and ended on a
  development build (`7.0.0-dev.20260707.2`). The TypeScript team describes it
  as the former nightly channel; stable and future nightly builds use the
  standard `typescript` package (`latest` and `next`, respectively).

Sources: [TypeScript 7 release announcement], [`typescript@7.0.2` package],
[`@typescript/native-preview` package], [Mason `tsc` package],
[Mason `tsgo` deprecation], [nvim-lspconfig command implementation].

## nvim-lspconfig behavior

The `tsc` config:

- supports `javascript`, `javascriptreact`, `typescript`, and
  `typescriptreact`;
- searches, in order, for project-local `tsc`, PATH `tsc`, project-local
  `tsgo`, then PATH `tsgo`;
- accepts a candidate only when `<binary> --version` parses to major version 7
  or newer, so a project-local TypeScript 6 executable is skipped in favor of a
  qualifying PATH executable;
- caches the selected executable once per resolved project root, then starts it
  with `--lsp --stdio`;
- warns and does not attach if no qualifying executable exists.

For root detection, package-manager lockfiles (`package-lock.json`, `yarn.lock`,
`pnpm-lock.yaml`, `bun.lockb`, or `bun.lock`) are preferred over `.git`. Deno
roots are excluded. With no project marker, the config falls back to Neovim's
current working directory. The TypeScript 7 server itself discovers the
appropriate `tsconfig.json` or `jsconfig.json` inside a monorepo, so one server
process can serve its packages.

The default settings key is `settings["js/ts"]`; nvim-lspconfig enables inlay
hints and reference/implementation CodeLens settings there.

Source: [nvim-lspconfig `tsc.lua`].

## Migration from `ts_ls`

1. Upgrade nvim-lspconfig to at least commit
   `3fc5c454b5a903049c8096b34e60ed30d1891aae` (or current master). Earlier pins
   predate either `tsc` entirely or its guard against selecting TypeScript 6.
2. Replace `ts_ls` with `tsc` and do not enable both. Both configs target the
   same four JavaScript/TypeScript filetypes, so enabling both can attach two
   clients to one buffer.
3. Remove `ts_ls`-specific `init_options`, including `hostInfo` and
   `tsserver.fallbackPath`. `tsc` is the native LSP and does not use a
   JavaScript `tsserver.js` fallback.
4. Do not assume nvim-lspconfig's `ts_ls` helper commands migrate. `ts_ls`
   defines `:LspTypescriptSourceAction` and
   `:LspTypescriptGoToSourceDefinition`; the `tsc` config does not define those
   client-side commands. Standard LSP code actions and definitions remain the
   appropriate interface.
5. Keep TypeScript 6 for projects that require ES5, language-service plugins,
   or embedded-language tooling. TypeScript 7.0 has no stable programmatic API;
   the TypeScript team specifically calls out Vue, MDX, Astro, Svelte, and
   Angular template workflows as not yet able to use the TypeScript 7 language
   service. nvim-lspconfig likewise notes that `ts_ls` remains useful for ES5.
6. Expect TypeScript 7 compiler-contract changes even if only the editor server
   changes. Notable examples include `strict: true`, `types: []`, and a
   project-root default for `rootDir`; deprecated options such as `target: es5`,
   `baseUrl`, and `moduleResolution: node` are rejected.

Sources: [nvim-lspconfig `ts_ls.lua`], [TypeScript 7 editor limitations],
[TypeScript 7 configuration changes].

## Recommended verification

After installation and configuration:

```sh
tsc --version
```

It must report major version 7 or newer. In Neovim, open a `.ts` file and use
`:checkhealth vim.lsp` (or `:LspInfo`) to confirm exactly one attached client
named `tsc` and a command ending in `--lsp --stdio`.

[TypeScript 7 release announcement]: https://devblogs.microsoft.com/typescript/announcing-typescript-7-0/
[`typescript@7.0.2` package]: https://www.npmjs.com/package/typescript/v/7.0.2
[`@typescript/native-preview` package]: https://www.npmjs.com/package/%40typescript/native-preview/v/7.0.0-dev.20260707.2
[Mason `tsc` package]: https://github.com/mason-org/mason-registry/blob/main/packages/tsc/package.yaml
[Mason `tsgo` deprecation]: https://github.com/mason-org/mason-registry/blob/main/packages/tsgo/package.yaml
[nvim-lspconfig `tsc` documentation]: https://github.com/neovim/nvim-lspconfig/blob/16286347bdba1333c7d124d9de9fe6630731b2b2/doc/configs.md#tsc
[nvim-lspconfig `tsc.lua`]: https://github.com/neovim/nvim-lspconfig/blob/16286347bdba1333c7d124d9de9fe6630731b2b2/lsp/tsc.lua
[nvim-lspconfig command implementation]: https://github.com/neovim/nvim-lspconfig/blob/16286347bdba1333c7d124d9de9fe6630731b2b2/lsp/tsc.lua#L51-L145
[deprecated `tsgo` alias]: https://github.com/neovim/nvim-lspconfig/blob/16286347bdba1333c7d124d9de9fe6630731b2b2/lsp/tsgo.lua
[nvim-lspconfig `ts_ls.lua`]: https://github.com/neovim/nvim-lspconfig/blob/16286347bdba1333c7d124d9de9fe6630731b2b2/lsp/ts_ls.lua
[the introducing commit]: https://github.com/neovim/nvim-lspconfig/commit/033492baa0972c1a9e3916fc8d634ae6a9b8b155
[the version-selection fix]: https://github.com/neovim/nvim-lspconfig/commit/3fc5c454b5a903049c8096b34e60ed30d1891aae
[TypeScript 7 editor limitations]: https://devblogs.microsoft.com/typescript/announcing-typescript-7-0/#typescript-and-embedded-languages
[TypeScript 7 configuration changes]: https://devblogs.microsoft.com/typescript/announcing-typescript-7-0/#updates-since-5-x-and-new-behaviors-from-6-0
