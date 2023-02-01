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

{: pack : setup! : cmd}

