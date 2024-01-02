# Editors

## Glossary

### LSP - Language Server Protocol

> https://en.wikipedia.org/wiki/Language_Server_Protocol

> https://langserver.org/

The Language Server Protocol (LSP) is an open, JSON-RPC-based protocol for use between source code editors or integrated development environments (IDEs) and servers that provide programming language-specific features like:

- **code completion**
- **syntax highlighting**
- **marking of warnings and errors**
- **refactoring routines**

The goal of the protocol is to allow programming language support to be implemented and distributed independently of any given editor or IDE.

LSP was originally developed for Microsoft Visual Studio Code and is now an open standard.
In the early 2020s LSP quickly became a "norm" for language intelligence tools providers.

### Tree-sitter

> https://tree-sitter.github.io/tree-sitter/

> https://www.reddit.com/r/neovim/comments/1109wgr/treesitter_vs_lsp_differences_ans_overlap/
 
Tree-sitter is a parser generator tool and an **incremental parsing** library. It can build a concrete syntax tree for a source file and efficiently update the syntax tree as the source file is edited.

It is used by many editors and IDEs to provide:

- **syntax highlighting**
- **indentation**
- **creating foldable code regions**
- **Incremental selection**
- **refactoring**
    - such as join/split lines.

**Treesitter does, however, have limited knowledge of your code**, and it is not aware of the semantics of your code. For example, it does not know does a function/variable really exist, or what is the type/return-type of a variable. This is where LSP comes in.

**The LSP server parses the code much more deeply and it not only parses a single file but your whole project**. So, the LSP server will know whether a function/variable does exist with the same type/return-type. If it does not, it will mark it as an error. 

**LSP does understand the code semantically, while Treesitter only cares about correct syntax**.

### LSP vs Tree-sitter

- Tree-sitter: lightweight, fast, but limited knowledge of your code. mainly used for **syntax highlighting, indentation, and folding/refactoring in a single file**.
- LSP: heavy and slow on large projects, but it has a deep understanding of your code. mainly used for **code completion, refactoring in the projects, errors/warnings, and other semantic-aware features**.

