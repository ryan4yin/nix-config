; Mapping data with "desc" stored directly by vim.keymap.set().
;
; Please use this mappings table to set keyboard mapping since this is the
; lower level configuration and more robust one. (which-key will)
; automatically pick-up stored data by this setting.
(local utils (require :astronvim.utils))
((. (require :telescope) :load_extension) :refactoring)
((. (require :telescope) :load_extension) :yank_history)
((. (require :telescope) :load_extension) :undo)
{:n {:<C-s> {1 ":w!<cr>" :desc "Save File"}
     ;; second key is the lefthand side of the map
     ;; mappings seen under group name "Buffer"
     :<leader>bn {1 :<cmd>tabnew<cr> :desc "New tab"}
     :<leader>rb {1 (fn []
                      ((. (require :refactoring) :refactor) "Extract Block"))
                  :desc "Extract Block"}
     :<leader>rbf {1 (fn []
                       ((. (require :refactoring) :refactor) "Extract Block To File"))
                   :desc "Extract Block To File"}
     :<leader>rc {1 (fn []
                      ((. (. (require :refactoring) :debug) :cleanup) {}))
                  :desc "Cleanup of all generated print statements"}
     :<leader>ri {1 (fn []
                      ((. (require :refactoring) :refactor) "Inline Variable"))
                  :desc "Inverse of extract variable"}
     :<leader>rp {1 (fn []
                      ((. (. (require :refactoring) :debug) :printf) {:below false}))
                  :desc "Insert print statement to mark the calling of a function"}
     :<leader>rr {1 (fn []
                      ((. (. (. (require :telescope) :extensions) :refactoring)
                          :refactors)))
                  :desc "Prompt for a refactor to apply"}
     :<leader>rv {1 (fn []
                      ((. (. (require :refactoring) :debug) :print_var)))
                  :desc "Insert print statement to print a variable"}
     :<leader>sp {1 "<cmd>lua require(\"spectre\").open_file_search({select_word=true})<CR>"
                  :desc "Search on current file"}
     :<leader>ss {1 "<cmd>lua require(\"spectre\").toggle()<CR>"
                  :desc "Toggle Spectre"}
     :<leader>sw {1 "<cmd>lua require(\"spectre\").open_visual({select_word=true})<CR>"
                  :desc "Search current word"}
     :<leader>uh {1 "<cmd>Telescope undo<cr>" :desc "Telescope undo"}
     :<leader>yh {1 (fn []
                      ((. (. (. (require :telescope) :extensions) :yank_history)
                          :yank_history)))
                  :desc "Preview Yank History"}
     :gP {1 "<cmd>lua require('goto-preview').close_all_win()<CR>"
          :desc :close_all_win}
     :gpd {1 "<cmd>lua require('goto-preview').goto_preview_definition()<CR>"
           :desc :goto_preview_definition}
     :gpi {1 "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>"
           :desc :goto_preview_implementation}
     :gpr {1 "<cmd>lua require('goto-preview').goto_preview_references()<CR>"
           :desc :goto_preview_references}
     :gpt {1 "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>"
           :desc :goto_preview_type_definition}}
 :v {:<leader>sw {1 "<esc><cmd>lua require(\"spectre\").open_visual()<CR>"
                  :desc "Search current word"}}
 :x {:<leader>re {1 (fn []
                      ((. (require :refactoring) :refactor) "Extract Function"))
                  :desc "Extracts the selected code to a separate function"}
     :<leader>rf {1 (fn []
                      ((. (require :refactoring) :refactor) "Extract Function To File"))
                  :desc "Extract Function To File"}
     :<leader>ri {1 (fn []
                      ((. (require :refactoring) :refactor) "Inline Variable"))
                  :desc "Inverse of extract variable"}
     :<leader>rr {1 (fn []
                      ((. (. (. (require :telescope) :extensions) :refactoring)
                          :refactors)))
                  :desc "Prompt for a refactor to apply"}
     :<leader>rv {1 (fn []
                      ((. (require :refactoring) :refactor) "Extract Variable"))
                  :desc "Extracts occurrences of a selected expression to its own variable"}}}
