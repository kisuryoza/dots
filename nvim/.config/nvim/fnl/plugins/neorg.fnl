(import-macros {: pack} :macros)

(local M (pack :nvim-neorg/neorg {:build ":Neorg sync-parsers"
                                  :dependencies [:nvim-lua/plenary.nvim]
                                  :cmd :Neorg
                                  :ft :norg}))

(fn M.config []
  (let [neorg (require :neorg)]
    (neorg.setup {:load {:core.defaults {}
                         :core.norg.completion {:config {:engine :nvim-cmp}}
                         :core.integrations.nvim-cmp {}
                         :core.norg.concealer {}
                         :core.norg.dirman {:config {:workspaces {:notes "~/Sync/neorg"}}}
                         :core.norg.journal {:config {:strategy :flat}}}})))

M

