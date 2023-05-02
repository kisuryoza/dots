(import-macros {: pack} :macros)

(local M (pack :nvim-neorg/neorg {:build ":Neorg sync-parsers"
                                  :dependencies [:nvim-lua/plenary.nvim]
                                  :cmd :Neorg
                                  :ft :norg}))

(fn M.config []
  (let [neorg (require :neorg)]
    (neorg.setup {:load {:core.defaults {}
                         :core.completion {:config {:engine :nvim-cmp}}
                         :core.integrations.nvim-cmp {}
                         :core.concealer {}
                         :core.dirman {:config {:workspaces {:notes "~/Sync/neorg"}}}
                         :core.journal {:config {:strategy :flat}}}})))

M

