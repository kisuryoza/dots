(defconst local-bin (expand-file-name (file-name-as-directory "~/.local/bin")))

(setq user-full-name "Alex"
      user-mail-address "")

(global-auto-revert-mode 1)
(setq undo-limit 80000000
      evil-want-fine-undo t
      auto-save-default nil
      inhibit-compacting-font-caches t)
(whitespace-mode -1)

(setq-default
    delete-by-moving-to-trash t
    trash-directory "~/.local/share/Trash/files/"
    tab-width 4
    uniquify-buffer-name-style 'forward
    window-combination-resize t
    x-stretch-cursor nil
    require-final-newline t) ;; Auto create a newline at end of file

(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

(setq scroll-margin 1
      scroll-step 1
      scroll-conservatively 10000
      smooth-scroll-margin 1)

(setq org-directory "~/org/")

(after! org
  (setq org-startup-folded 'show2levels
        org-ellipsis " [...] "
))

(after! org
  (custom-set-faces!
    '(org-level-1 :height 1.15 :inherit outline-1)
    '(org-level-2 :height 1.13 :inherit outline-2)
    '(org-level-3 :height 1.11 :inherit outline-3)
    '(org-level-4 :height 1.09 :inherit outline-4)
    '(org-level-5 :height 1.07 :inherit outline-5)
    '(org-level-6 :height 1.05 :inherit outline-6)
    '(org-level-7 :height 1.03 :inherit outline-7)
    '(org-level-8 :height 1.01 :inherit outline-8)))

(after! org
  (custom-set-faces!
    '(org-document-title :height 1.15)))

(defun org/prettify-set ()
    (interactive)
    (setq prettify-symbols-alist
        '(("#+begin_src" . "")
          ("#+BEGIN_SRC" . "")
          ("#+end_src" . "")
          ("#+END_SRC" . "")
          ("#+begin_example" . "")
          ("#+BEGIN_EXAMPLE" . "")
          ("#+end_example" . "")
          ("#+END_EXAMPLE" . "")
          ("#+results:" . "")
          ("#+RESULTS:" . "")
          ("#+begin_quote" . "❝")
          ("#+BEGIN_QUOTE" . "❝")
          ("#+end_quote" . "❞")
          ("#+END_QUOTE" . "❞")
          ("[ ]" . "☐")
          ("[-]" . "◯")
          ("[X]" . "☑"))))
  (add-hook 'org-mode-hook 'org/prettify-set)

(use-package! org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode)
  :config
  (setq org-auto-tangle-default t))

(setq doom-theme 'doom-tomorrow-night)
; doom-one
; doom-tomorrow-night
(setq display-line-numbers-type t)
(after! doom-themes
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))
(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-keyword-face :slant italic))

(setq doom-font (font-spec :family "JetBrains Mono" :size 12 :weight 'Regular)
      doom-variable-pitch-font (font-spec :family "DejaVu Sans")
      doom-serif-font (font-spec :family "Iosevka Etoile")
      doom-unicode-font ()
      doom-big-font ())

(after! ccls
  (setq ccls-initialization-options '(:index (:comments 2) :completion (:detailedLabel t)))
  (set-lsp-priority! 'ccls 2)) ; optional as ccls is the default in Doom

(setq lsp-enable-indentation nil)

(beacon-mode 1)

(define-globalized-minor-mode global-rainbow-mode rainbow-mode
  (lambda () (rainbow-mode 1)))
(global-rainbow-mode 1 )

;; Whether display the perspective name. Non-nil to display in the mode-line.
(setq doom-modeline-persp-name t)
;; If non nil the perspective name is displayed alongside a folder icon.
(setq doom-modeline-persp-icon t)
;; Whether display the environment version.
(setq doom-modeline-env-version t)
;; What to display as the version while a new one is being loaded
(setq doom-modeline-env-load-string "...")

;(custom-set-faces!
;  '(mode-line :family "DejaVu Sans" :height 0.9)
;  '(mode-line-inactive :family "DejaVu Sans" :height 0.9))

(setq display-line-numbers-type t)
(map! :leader
      :desc "Comment or uncomment lines" "TAB TAB" #'comment-line)

(use-package! parinfer-rust-mode
  ;:when (bound-and-true-p module-file-suffix)
  :hook ((emacs-lisp-mode
          clojure-mode
          scheme-mode
          lisp-mode
          racket-mode
          hy-mode) . parinfer-rust-mode)
  :init
  (setq parinfer-rust-library
        (expand-file-name "~/gitclone/parinfer-rust/target/release/libparinfer_rust.so"))
  (setq parinfer-rust-check-before-enable 'nil))

(setq centaur-tabs-style "bar"
      centaur-tabs-height 30
      centaur-tabs-set-icons t
      centaur-tabs-gray-out-icons 'buffer
      centaur-tabs-set-bar 'under
      centaur-tabs-set-modified-marker t
      x-underline-at-descent-line t
)
(define-key evil-normal-state-map (kbd "g t") 'centaur-tabs-forward)
(define-key evil-normal-state-map (kbd "g T") 'centaur-tabs-backward)
;; (centaur-tabs-group-by-projectile-project)
