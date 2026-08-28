;;; keybinds.el --- My emacs bindings  -*- lexical-binding:t; coding:utf-8 -*-

(global-unset-key (kbd "C-z"))
(global-unset-key (kbd "C-s"))
(global-unset-key (kbd "C-v"))
(global-unset-key (kbd "C-v"))

(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "C-v") #'clipboard-yank)
  (define-key evil-visual-state-map (kbd "C-v") #'clipboard-yank)
  (define-key evil-insert-state-map (kbd "C-v") #'clipboard-yank))

(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "C-c") #'clipboard-kill-ring-save)
  (define-key evil-visual-state-map (kbd "C-c") #'clipboard-kill-ring-save)
  (define-key evil-insert-state-map (kbd "C-c") #'clipboard-kill-ring-save))

(evil-set-leader 'normal (kbd "SPC"))
(evil-set-leader 'visual (kbd "SPC"))

(evil-define-key 'normal 'global (kbd "<leader>fs") 'save-buffer)

  ; "ld" 'lsp-bridge-find-def
  ; "lr" 'lsp-bridge-find-references
  ; "li" 'lsp-bridge-find-impl

(setq evil-lookup-func 'lsp-bridge-popup-documentation)

; gd goto definition

(global-set-key [C-mouse-wheel-up-event]  'text-scale-increase)
(global-set-key  [C-mouse-wheel-down-event] 'text-scale-decrease)

(global-set-key [C-=]  'text-scale-increase)
(global-set-key [C-+]  'text-scale-increase)
(global-set-key  [C--] 'text-scale-decrease)
