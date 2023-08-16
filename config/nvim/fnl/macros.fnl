(λ pack [package ?options]
  (let [options (or ?options {})
        array (collect [k v (pairs options)]
                (values k v))]
    (tset array 1 package)
    `,array))

(λ setup! [module]
  `(. (require ,module) :setup))

(λ cmd [command]
  (.. :<cmd> command :<CR>))

(λ nmap [key func desc ?buffer]
  (if (= nil ?buffer)
    `(vim.keymap.set :n ,key ,func {:desc ,desc})
    `(vim.keymap.set :n ,key ,func {:desc ,desc :buffer ,?buffer})))

{: pack : setup! : cmd : nmap}

