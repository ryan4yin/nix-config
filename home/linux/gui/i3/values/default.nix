{mylib, ...} @ args:
map
(path: import path args)
(mylib.scanPaths ./.)
