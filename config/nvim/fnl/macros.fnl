;; fennel-ls: macro-file
(lambda pack [package ?options]
  (let [options (or ?options {})
        array (collect [k v (pairs options)]
                (values k v))]
    (tset array 1 package)
    `,array))

(lambda setup! [module]
  `(. (require ,module) :setup))

(lambda set! [k v]
  `(tset vim.opt ,k ,v))

(lambda cmd! [command]
  (.. :<cmd> command :<CR>))

(fn tset-if-not-nill [table property value]
  "In table assigns value to property if value is not nill"
  (if (not= nil value)
      (tset table property value))
  table)

(fn map! [mode key func desc buffer]
  (var opts {}) ;{:silent true})
  (set opts (tset-if-not-nill opts :desc desc))
  (set opts (tset-if-not-nill opts :buffer buffer))
  `(vim.keymap.set ,mode ,key ,func ,opts))

(fn nmap! [key func desc buffer]
  (map! :n key func desc buffer))

(fn vmap! [key func desc buffer]
  (map! :v key func desc buffer))

(fn nmapp! [key func desc buffer]
  (map! :n (.. :<leader> key) func desc buffer))

(lambda get_hl! [name side]
  `(. (vim.api.nvim_get_hl 0 {:name ,name :link false}) ,side))

(lambda get_hl_fg! [name]
  (get_hl! name :fg))

(lambda get_hl_bg! [name]
  (get_hl! name :bg))

{: pack
 : setup!
 : set!
 : cmd!
 : map!
 : nmap!
 : vmap!
 : nmapp!
 : get_hl_fg!
 : get_hl_bg!}

