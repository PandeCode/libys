;;; init.el --- My emacs config  -*- lexical-binding:t; coding:utf-8 -*-

;;; Basic UI
(setopt inhibit-startup-screen t)           ;; Skip splash screen
(setopt initial-scratch-message nil)        ;; Empty scratch buffer
(setopt ring-bell-function 'ignore)         ;; No annoying bell
(setopt visible-bell nil)                   ;; No visual bell either

;;; File handling
(setopt auto-save-default t)                ;; Auto-save files
(setopt backup-by-copying t)                ;; Better backups
(setopt create-lockfiles nil)               ;; Don't create .# files
(setopt make-backup-files t)                ;; Keep backup files
(setopt backup-directory-alist
        '(("." . "~/.emacs.d/backups")))    ;; Store backups in one place

;;; Behavior
(setopt confirm-kill-emacs 'yes-or-no-p)   ;; Confirm before quitting
(setopt scroll-conservatively 101)          ;; Smooth scrolling
(setopt mouse-wheel-scroll-amount '(1))     ;; One line per scroll
(setopt electric-pair-mode t)               ;; Auto-close brackets
