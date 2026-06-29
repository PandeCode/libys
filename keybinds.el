;;; keybinds.el --- My emacs bindings  -*- lexical-binding:t; coding:utf-8 -*-


(evil-set-leader 'normal (kbd "SPC"))
(evil-set-leader 'visual (kbd "SPC"))

(evil-define-key 'normal 'global (kbd "<leader>fs") 'save-buffer)

  ; "ld" 'lsp-bridge-find-def
  ; "lr" 'lsp-bridge-find-references
  ; "li" 'lsp-bridge-find-impl

(setq evil-lookup-func 'lsp-bridge-popup-documentation)

; gd goto definition
