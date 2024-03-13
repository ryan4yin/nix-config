;;; init.el -*- lexical-binding: t; -*-

;; This file controls what Doom modules are enabled and what order they load
;; in. Remember to run 'doom sync' after modifying it!

;; NOTE Press 'SPC h d h' (or 'C-h d h' for non-vim users) to access Doom's
;;      documentation. There you'll find a link to Doom's Module Index where all
;;      of our modules are listed, including what flags they support.

;; NOTE Move your cursor over a module's name (or its flags) and press 'K' (or
;;      'C-c c k' for non-vim users) to view its documentation. This works on
;;      flags as well (those symbols that start with a plus).
;;
;;      Alternatively, press 'gd' (or 'C-c c d') on a module to browse its
;;      directory (for easy access to its source code).


(doom! :input
       ;;bidi              ; (tfel ot) thgir etirw uoy gnipleh
       chinese
       ;;japanese
       ;;layout            ; auie,ctsrnm is the superior home row

       :completion
       ;; (company +childframe)  ; conflict with lsp-bridge
                                        ; the ultimate code completion backend
       ;;helm              ; the *other* search engine for love and life
       ;;ido               ; the other *other* search engine...
       ;;ivy               ; a search engine for love and life
       vertico                          ; the search engine of the future

       :ui
       ;;deft              ; notational velocity for Emacs
       doom                             ; what makes DOOM look the way it does
       doom-dashboard                   ; a nifty splash screen for Emacs
       ;;doom-quit         ; DOOM quit-message prompts when you quit Emacs
       ;; (emoji +unicode) ; Emacs 29 provides native support for inserting Unicode emojis.
                                        ; 🙂
       hl-todo            ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW
       indent-guides      ; highlighted indent columns
       ligatures          ; ligatures and symbols to make your code pretty again
       modeline           ; snazzy, Atom-inspired modeline, plus API
       ophints            ; highlight the region an operation acts on
       (popup +defaults)
                                        ; tame sudden yet inevitable temporary windows
       tabs                             ; a tab bar for Emacs
       treemacs                 ; a project drawer, like neotree but cooler
       unicode                  ; extended unicode support for various languages
       (vc-gutter +pretty)
                                        ; vcs diff in the fringe
       vi-tilde-fringe                  ; fringe tildes to mark beyond EOB
       ;;window-select     ; visually switch windows
       workspaces       ; tab emulation, persistence & separate workspaces
       ;;zen               ; distraction-free coding or writing

       :editor
       (evil +everywhere)
                                        ; come to the dark side, we have cookies
       file-templates                   ; auto-snippets for empty files
       fold                             ; (nigh) universal code folding
       (format +onsave)
                                        ; automated prettiness
       ;; multiple-cursors  ; editing in many places at once
       ;; objed             ; text object editing for the innocent, conflict with parinfer
       parinfer          ; turn lisp into python, sort of, conflict with copilot/objed/smartparens
       ;;rotate-text       ; cycle region at point between text candidates
       snippets   ; my elves. They type so I don't have to
       word-wrap         ; soft wrapping with language-aware indent

       :emacs
       dired             ; making dired pretty [functional]
       electric          ; smarter, keyword-based electric-indent
       ibuffer         ; interactive buffer management
       undo              ; persistent, smarter undo for your inevitable mistakes
       vc                ; version-control and Emacs, sitting in a tree

       :term
       ;;eshell            ; the elisp shell that works everywhere
       ;;shell             ; simple shell REPL for Emacs
       ;;term              ; basic terminal emulator for Emacs
       vterm                            ; the best terminal emulation in Emacs

       :checkers
       syntax                        ; tasing you for every semicolon you forget
       (spell +flyspell)
                                        ; tasing you for misspelling mispelling
       grammar                          ; tasing grammar mistake every you make

       :tools
       ;;ansible
       ;;biblio            ; Writes a PhD for you (citation needed)
       ;;collab            ; buffers with friends
       ;;debugger          ; FIXME stepping through code, to help you add bugs
       ;;direnv
       (docker)
       editorconfig      ; let someone else argue about tabs vs spaces
       ;;ein               ; tame Jupyter notebooks with emacs
       (eval +overlay)
                                        ; run code, run (also, repls)
       lookup                   ; navigate your code and its documentation
       lsp    ; lsp-mode, conflict with lsp-bridge
       magit                    ; a git porcelain for Emacs
       ;;make              ; run make tasks from Emacs
       ;;pass              ; password manager for nerds
       pdf                              ; pdf enhancements
       ;;prodigy           ; FIXME managing external services & code builders
       (terraform)
                                        ; infrastructure as code
       tree-sitter                    ; syntax and parsing, sitting in a tree...
       ;;upload            ; map local to remote projects via ssh/ftp

       :os
       (:if IS-MAC macos)
                                        ; improve compatibility with macOS
       tty                              ; improve the terminal Emacs experience

       :lang
       ;;agda              ; types of types of types of types...
       ;;beancount         ; mind the GAAP
       (cc +lsp +tree-sitter)
                                        ; C > C++ == 1
       ;;clojure           ; java with a lisp
       ;;common-lisp       ; if you've seen one lisp, you've seen them all
       ;;coq               ; proofs-as-programs
       ;;crystal           ; ruby at the speed of c
       ;;csharp            ; unity, .NET, and mono shenanigans
       data                     ; config/data formats
       ;;(dart +flutter)   ; paint ui and not much else
       ;;dhall
       ;;elixir            ; erlang done right
       ;;elm               ; care for a cup of TEA?
       emacs-lisp                       ; drown in parentheses
       ;;erlang            ; an elegant language for a more civilized age
       ;;ess               ; emacs speaks statistics
       ;;factor
       ;;faust             ; dsp, but you get to keep your soul
       ;;fortran           ; in FORTRAN, GOD is REAL (unless declared INTEGER)
       ;;fsharp            ; ML stands for Microsoft's Language
       ;;fstar             ; (dependent) types and (monadic) effects and Z3
       ;;gdscript          ; the language you waited for
       (go +lsp +tree-sitter)  ;; disable go-mode, use lsp-bridge instead
                                        ; the hipster dialect
       ;;(graphql)    ; Give queries a REST
       ;;(haskell)    ; a language that's lazier than I am
       ;;hy                ; readability of scheme w/ speed of python
       ;;idris             ; a language you can depend on
       (json +lsp +tree-sitter)
                                        ; At least it ain't XML
       (java +lsp +tree-sitter)
                                        ; the poster child for carpal tunnel syndrome
       (javascript +lsp +tree-sitter)
                                        ; all(hope(abandon(ye(who(enter(here))))))
       ;;julia             ; a better, faster MATLAB
       ;;kotlin            ; a better, slicker Java(Script)
       (latex)
                                        ; writing papers in Emacs has never been so fun
       ;;lean              ; for folks with too much to prove
       ;;ledger            ; be audit you can be
       (lua +lsp +tree-sitter)
                                        ; one-based indices? one-based indices
       (markdown +grip)
                                        ; writing docs for people to ignore
       ;;nim               ; python + lisp at the speed of c
       (nix +lsp +tree-sitter)
                                        ; I hereby declare "nix geht mehr!"
       ;;ocaml             ; an objective camel
       (org +pandoc +hugo +jupyter)  ; organize your plain life in plain text
       ;;php               ; perl's insecure younger brother
       ;;plantuml          ; diagrams for confusing people more
       ;;purescript        ; javascript, but functional
       (python +lsp +tree-sitter +pyright)
                                        ; beautiful is better than ugly
       ;;qt                ; the 'cutest' gui framework ever
       racket           ; a DSL for DSLs
       ;;raku              ; the artist formerly known as perl6
       ;;rest              ; Emacs as a REST client
       ;;rst               ; ReST in peace
       ;;(ruby +rails)     ; 1.step {|i| p "Ruby is #{i.even? ? 'love' : 'life'}"}
       (rust +lsp +tree-sitter)
                                        ; Fe2O3.unwrap().unwrap().unwrap().unwrap()
       ;;scala             ; java, but good
       (scheme +guile)
                                        ; a fully conniving family of lisps
       (sh +lsp +tree-sitter)
                                        ; she sells {ba,z,fi}sh shells on the C xor
       ;;sml
       ;;solidity          ; do you need a blockchain? No.
       ;;swift             ; who asked for emoji variables?
       ;;terra             ; Earth and Moon in alignment for performance.
       (web +lsp +tree-sitter)
                                        ; support for various web languages, including HTML5, CSS, SASS/SCSS, Pug/Jade/Slim, and more
       (yaml +lsp +tree-sitter)
                                        ; JSON, but readable
       ;;zig               ; C, but simpler

       :email
       ;;(mu4e +org +gmail)
       ;;notmuch
       ;;(wanderlust +gmail)

       :app
       ;;calendar
       ;;emms
       ;;everywhere        ; *leave* Emacs!? You must be joking
       ;;irc               ; how neckbeards socialize
       ;;(rss +org)        ; emacs as an RSS reader
       ;;twitter           ; twitter client https://twitter.com/vnought

       :config
       ;;literate
       (default +bindings +smartparens))
