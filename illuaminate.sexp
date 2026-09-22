; -*- mode: Lisp;-*-

;; Only lint our own code: src/ holds the scripts, build/ holds tl output and
;; libs/ holds code fetched from pastebin at runtime.
(sources
  /src)

(at /
 ;; CC scripts are single-file programs rather than documented modules, so the
 ;; doc-comment and unresolved-member warnings are noise here.
 (linters all -doc:undocumented -doc:undocumented-arg -doc:undocumented-return -var:unresolved-member)

 (lint
   ;; CC:Tweaked's globals, on top of the Lua 5.1 ones illuaminate knows about.
   (globals
     :max
     colors colours commands disk fs gps help http keys multishell paintutils
     parallel peripheral pocket rednet redstone rs settings shell term textutils
     turtle vector window
     printError read sleep write _HOST _CC_DEFAULT_SETTINGS)

   (table-separator comma)
   (quote double)
   (allow-toplevel-global false)
   (allow-clarifying-parens true)
   (allow-empty-if false)))
