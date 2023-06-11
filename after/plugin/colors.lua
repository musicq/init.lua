function ColorMyPencils(color)
	color = color or "vscode"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

ColorMyPencils()

vim.g.airline_theme = "base16_material_darker"
