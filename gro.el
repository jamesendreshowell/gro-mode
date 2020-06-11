;;; gro.el --- Freewriting without editing: "growing" writing.

;; Copyright (c) 2020 James Endres Howell
;; 
;; Author: James Endres Howell <james@endres-howell.org>
;; 
;; Special Thanks: Peter Elbow, Xah Lee
;; 
;; This file is not part of GNU Emacs.
;; 
;; gro.el is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;; 
;; gro.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with gro.el.  If not, see <http://www.gnu.org/licenses/>.


;;; Commentary:

;; This package provides a major mode for typing text without the
;; ability to revise or edit that text. This mode encourages
;; "freewriting," for simply getting text out of your head without
;; reflection or self-censorship.
;;
;; Inspired by Elbow's (_Writing Without Teachers_, 1973) distinction
;; between "growing" vs. "cooking" writing.
;;
;; https://en.wikipedia.org/wiki/Peter_Elbow#Writing_Without_Teachers
;;
;; Named for the use of freewriting in the process of "growing"
;; writing. Also named in (backwards) homage to Org-mode, which works
;; very well for "cooking" writing.


;;; Code:


;;; Provide visual/audible feedback for disabled keys:

(defvar gro-feedback-insert-string "×"
  "String to insert at point when an inactivated key is pressed.
Set to \"\" to disable.")

(defvar gro-feedback-message-string "Growing! Editing keys disabled."
  "String to display in message box when an inactivated key is pressed.
Set to \"\" to disable.")

(defvar gro-feedback-bell t
  "non-nil: audible bell as feedback when an inactivated key is pressed.
Set to nil to disable.")

(defvar gro-feedback-modeline-flash t
  "non-nil: flashing modeline as feedback when an inactivated key is pressed.
Set to nil to disable.")

;; Stolen from https://www.emacswiki.org/emacs/AlarmBell
(defun gro-flash-mode-line ()
  "Provide subtle visual feedback by briefly inverting the modeline."
  (invert-face 'mode-line)
  (run-with-timer 0.1 nil #'invert-face 'mode-line))


;;; Focus: only show a few lines

(defvar gro-focus-lines 3
  "Number of lines of text to display in the buffer when `gro-focus-switch' is non-nil.")

(defvar gro-focus-switch nil
  "Set by `gro-focus-toggle'.

non-nil: focus on `gro-focus-lines' lines;
nil:    focus is inactive")

(defun gro-focus-adjust-buffer ()
  "Adjust buffer view so that only `gro-focus-lines' of text are visible above point."
;;; ASSERT: point is at 'end-of-buffer
  (interactive)
  (recenter-top-bottom (- gro-focus-lines 1))
)

(defun gro-focus-toggle ()
  "Activate/inactivate \"focus,\" displaying only `gro-focus-lines' lines of text in the buffer."
  (interactive)
  (if (eq gro-focus-switch nil)
      (progn 
	(message (concat "Gro focus: displaying last " (number-to-string gro-focus-lines) " lines."))
	(setq gro-focus-switch t)
	;; (add-hook HOOK FUNCTION &optional APPEND LOCAL)
	(add-hook 'post-self-insert-hook 'gro-focus-adjust-buffer nil t) ;; buffer-local
       )
    (progn 
      (message "Gro focus off.")
      (setq gro-focus-switch nil)
      ;; (remove-hook HOOK FUNCTION &optional LOCAL)
      (remove-hook 'post-self-insert-hook 'gro-focus-adjust-buffer t) ;; buffer-local
      )))


;;; Insert timestamp:

(defvar gro-date-time-format
  "%A %Y %B %d %R"
; e.g. Tuesday 2020 June 09 13:54
  "See `format-time-string' for possible values.")

(defun gro-insert-timestamp ()
  "Insert timestamp of the format `gro-date-time-format', e.g. for a running journal file."
  (interactive)
  (insert (concat "\n\n" (format-time-string gro-date-time-format (current-time)) "\n")))



;;; The main function:

(defun gro-key-disabled-feedback ()
  "Provide feedback that editing keys are disabled in `gro-mode'.
See: `gro-feedback-bell', `gro-feedback-modeline-flash', `gro-feedback-message-string', and `gro-feedback-insert-string'."
  (interactive)
  (if gro-feedback-bell (ding))
  (if gro-feedback-modeline-flash (gro-flash-mode-line))
  (message gro-feedback-message-string)
  (insert gro-feedback-insert-string)
  (save-excursion (gro-focus-adjust-buffer))
)


;; Initialize the keymap, then remap editing keys.
(defvar gro-mode-map nil "Keymap for `gro-mode'.")
(setq gro-mode-map (make-sparse-keymap))

(define-key gro-mode-map (kbd "M-<") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "M->") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-v") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "M-v") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-S-v") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "M-V") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "M-{") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "M-}") 'gro-key-disabled-feedback)

(define-key gro-mode-map (kbd "C-a") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-e") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-f") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-b") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-p") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-n") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-S-a") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-S-e") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-S-f") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-S-b") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-S-p") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-S-n") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-S-d") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "M-a") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "M-e") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "M-f") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "M-b") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "M-p") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "M-n") 'gro-key-disabled-feedback)

(define-key gro-mode-map (kbd "C-k") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-S-k") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<deleteline>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-o") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-S-o") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<insertline>") 'gro-key-disabled-feedback)

(define-key gro-mode-map (kbd "<next>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<prior>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<home>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<end>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<insert>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<delete>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<C-next>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<C-prior>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<C-home>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<C-end>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<C-insert>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<C-delete>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<M-next>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<M-prior>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<M-home>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<M-end>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<M-insert>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<M-delete>") 'gro-key-disabled-feedback)

(define-key gro-mode-map (kbd "<right>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<left>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<up>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<down>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<backspace>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<deletechar>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<C-right>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<C-left>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<C-up>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<C-down>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<C-backspace>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<C-deletechar>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<M-right>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<M-left>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<M-up>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<M-down>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<M-backspace>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<M-deletechar>") 'gro-key-disabled-feedback)


;;; Shortcut keys:
(define-key gro-mode-map (kbd "C-c C-f") 'gro-focus-toggle)
(define-key gro-mode-map (kbd "C-c C-c") 'gro-insert-timestamp)


(define-derived-mode gro-mode text-mode "gro"
  "Disallow most editing, except for inserting text.

Force the writer to continue \"freewriting\" without the ability to edit or revise.

Part of Elbow's process of \"growing\" writing.")

;;; Files named *.gro will open in gro-mode.
(add-to-list 'auto-mode-alist '("\\.gro\\'" . gro-mode))

;;; Upon starting gro-mode, move point to the end of the buffer.
;;; E.g. for revisiting a file containing a notebook or journal
;;; of freewriting. In gro-mode moving point is disabled!
(add-hook 'gro-mode-hook 'end-of-buffer)


(provide 'gro)

;;; gro.el ends here
