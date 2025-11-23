;; The init.scm file is run at the top level, immediately after the helix.scm module is required.
;; The helix context is available here, so you can interact with the editor.

;; configure the LSP for steel
(require "helix/configuration.scm")
(define-lsp "steel-language-server" (command "steel-language-server") (args '()))
(define-language "scheme"
                 (language-servers '("steel-language-server")))

;; show splash screen - when you open with no argument
(require "mattwparas-helix-package/splash.scm")
(when (equal? (command-line) '("hx"))
  (show-splash))

;; Terminal & shell
(require "steel-pty/term.scm")
(set-default-shell! "nu")

;; File Watcher
(require "helix-file-watcher/file-watcher.scm")
(spawn-watcher)

;; File Tree
(require "mattwparas-helix-package/cogs/file-tree.scm")
