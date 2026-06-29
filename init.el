;;; init.el --- My emacs config  -*- lexical-binding:t; coding:utf-8 -*-

(setq read-process-output-max (* 1024 1024)) ;; 1mb
(setq display-fill-column-indicator-column 80)
(global-display-fill-column-indicator-mode 1)

;;; Basic UI
(setopt inhibit-startup-screen t)
(setopt initial-scratch-message nil)
(setopt ring-bell-function 'ignore)         ;; No annoying bell
(setopt visible-bell nil)                   ;; No visual bell either

;;; File handling
(setopt auto-save-default t)
(setopt backup-by-copying t)                ;; Better backups
(setopt create-lockfiles nil)               ;; Don't create .# files
(setopt make-backup-files t)                ;; Keep backup files
(setopt backup-directory-alist
        '(("." . "~/.emacs.d/backups")))    ;; Store backups in one place

(setopt scroll-conservatively 101)          ;; Smooth scrolling
(setopt mouse-wheel-scroll-amount '(1))     ;; One line per scroll
(setopt electric-pair-mode t)               ;; Auto-close brackets

(which-key-mode 1)

(load-theme 'base16-onedark t)


(require 'evil)
(evil-mode 1)
(setq evil-undo-system 'undo-redo)

;; Set the cursor color based on the evil state
(defvar my/base16-colors base16-onedark-theme-colors)
(setq evil-emacs-state-cursor   `(,(plist-get my/base16-colors :base0D) box)
      evil-insert-state-cursor  `(,(plist-get my/base16-colors :base0D) bar)
      evil-motion-state-cursor  `(,(plist-get my/base16-colors :base0E) box)
      evil-normal-state-cursor  `(,(plist-get my/base16-colors :base0B) box)
      evil-replace-state-cursor `(,(plist-get my/base16-colors :base08) bar)
      evil-visual-state-cursor  `(,(plist-get my/base16-colors :base09) box))

(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

(defun my-evil-relative-line-numbers ()
  (setq display-line-numbers 'relative))

(defun my-evil-absolute-line-numbers ()
  (setq display-line-numbers t))

(add-hook 'evil-normal-state-entry-hook
          #'my-evil-relative-line-numbers)

(add-hook 'evil-insert-state-entry-hook
          #'my-evil-absolute-line-numbers)

(require 'yasnippet)
(yas-global-mode 1)

(require 'lsp-bridge)
(global-lsp-bridge-mode)

; (set lsp-bridge-enable-inlay-hint t)

(load "~/libys/keybinds.el" nil t t)

; https://github.com/justinbarclay/parinfer-rust-mode
(require 'parinfer-rust-mode)

(add-hook 'emacs-lisp-mode 'parinfer-rust-mode)
(define-key parinfer-rust-mode-map (kbd "C-c C-p t") #'parinfer-rust-toggle-paren-mode)
(define-key parinfer-rust-mode-map (kbd "C-c C-p s") #'parinfer-rust-switch-mode)
(define-key parinfer-rust-mode-map (kbd "C-c C-p d") #'parinfer-rust-toggle-disable)
