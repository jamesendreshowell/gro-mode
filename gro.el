;;; gro.el --- Freewriting without editing: for "growing" writing.
;;
;; Copyright (c) 2020 James Endres Howell
;; 
;; Author: James Endres Howell <james@endres-howell.org>
;; 
;; Special Thanks: Peter Elbow, Xah Lee, Mickey Petersen
;;
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
;; Inspired by Elbow's (_Writing Without Teachers_, 1973)
;; <http://en.wikipedia.org/wiki/Peter_Elbow#Writing_Without_Teachers>
;;
;; Named for the use of freewriting in the process of "growing"
;; writing. Also named in (backwards) homage to Org-mode!


;;; Code:

;; Feedback: optional visual/audible feedback for disabled keys

(defvar gro-feedback-insert-string "×"
  "String to insert at point when an inactivated key is pressed.\nSet to \"\" to disable.")

(defvar gro-feedback-message-string "Growing! Editing keys disabled."
  "String to display in echo area when an inactivated key is pressed.\nSet to \"\" to disable.")

(defvar gro-feedback-bell t
  "non-nil: audible bell as feedback when an inactivated key is pressed.\nSet to nil to disable.")

(defvar gro-feedback-modeline-flash t
  "non-nil: flashing modeline as feedback when an inactivated key is pressed.\nSet to nil to disable.")

(defun gro-flash-mode-line ()
  "Provide subtle visual feedback by briefly inverting the modeline."
  ;; Stolen from https://www.emacswiki.org/emacs/AlarmBell
  (invert-face 'mode-line)
  (run-with-timer 0.1 nil #'invert-face 'mode-line))


;;; Focus: only show a few lines at a time

(defvar gro-focus-lines-limit 3
  "Maximum number of lines of text to display in the buffer when focus is activated.\n\nSee `gro-focus-toggle'.")

(defvar gro-focus-lines-dynamic-value gro-focus-lines-limit
  "Number of lines of text to display in the buffer.\n
If gro-focus-switch is t,   this variable gets set to `gro-focus-lines-limit' (or 1, whichever is higher).
If gro-focus-switch is nil, this variable gets set to `window-total-height'.")

(defvar gro-focus-switch nil
  "Set by `gro-focus-toggle'.")

(defun gro-focus-toggle ()
  "Switch between displaying `gro-focus-lines-limit' and `window-total-height' lines of text in the buffer."
  (interactive)
  (if gro-focus-switch
      ;;; gro-focus-switch is t: deactivate focus and toggle value to nil
      (progn 
	(setq gro-focus-lines-dynamic-value (window-total-height))
	(setq gro-focus-switch nil)
	(gro-post-self-insert-function)
	(message "Gro: displaying all lines.")
	)
      ;;; gro-focus-switch is nil: activate focus and toggle value to t
    (progn
      (setq gro-focus-lines-dynamic-value (if (< gro-focus-lines-dynamic-value 1) 1 gro-focus-lines-limit))
      (setq gro-focus-switch t)
      (gro-post-self-insert-function)
      (message (concat "Gro: displaying only the last " (number-to-string gro-focus-lines-dynamic-value)
		       (if (eq gro-focus-lines-dynamic-value 1) " line." " lines."))))))

(defun gro-post-self-insert-function ()
  (interactive)
;;; ASSERT: point is always at end-of-buffer
;;; The mode hook puts it there, and movement keys are disabled.
;;; This isn't really always true, but not a big priority to
;;; troubleshoot.
  (if (eq (buffer-local-value 'major-mode (current-buffer)) 'gro-mode)
      (progn
	(recenter-top-bottom (- gro-focus-lines-dynamic-value 1)))))

(add-hook 'post-self-insert-hook 'gro-post-self-insert-function)


;;; Timestamp

(defvar gro-timestamp-format  "%A %Y %B %d %R"
                      ;; e.g. Tuesday 2020 June 09 13:54
  "See `format-time-string' for possible values.")

(defun gro-timestamp-insert ()
  "Insert timestamp of the format `gro-date-time-format', e.g. for a running journal file."
  (interactive)
  (insert (concat "\n\n" (format-time-string gro-timestamp-format (current-time)) "\n"))
  (gro-post-self-insert-function))


;;; Keymap

;; All the keybindings below that are "disabled" call gro-key-disabled-feedback
;; in order to provide one or more of the optional methods of feedback.

(defun gro-key-disabled-feedback ()
  "Provide feedback that editing keys are disabled in `gro-mode'.
See: `gro-feedback-bell', `gro-feedback-modeline-flash', `gro-feedback-message-string', and `gro-feedback-insert-string'."
  (interactive)

  ;; Check to see if gro-enable-backspace has changed to t
  ;; and remap <backspace> if it has. There must be a more
  ;; elegant way to do this? Implemented this way, the first
  ;; backspace changes the mapping 
  (if gro-enable-backspace
      (define-key gro-mode-map (kbd "<backspace>") 'backward-delete-char-untabify))
  (if gro-feedback-bell (ding))
  (if gro-feedback-modeline-flash (gro-flash-mode-line))
  (message gro-feedback-message-string)
  (insert gro-feedback-insert-string)
  (gro-post-self-insert-function))

;; Initialize the keymap, then remap editing keys.
(defvar gro-mode-map nil "Keymap for `gro-mode'.")
(setq gro-mode-map (make-sparse-keymap))

(defvar gro-enable-backspace nil
  ;; KNOWN ISSUE: it would be more elegant with defcustom.
  ;; KNOWN ISSUE: it would be more elegant with a toggle function.
  "nil:     <backspace> maps to `gro-key-disabled-feedback';
non-nil: <backspace> maps to `backward-delete-char-untabify'.")

;; I presume that there is a simple way to loop over this list of keys
;; and assign them all to the same function, but I'm just learning
;; emacs lisp and I might change it later.
;; -----------------------
;; Inactivate editing keys
(define-key gro-mode-map (kbd "<backspace>") 'gro-key-disabled-feedback)

(define-key gro-mode-map (kbd "<deletechar>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<M-backspace>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<M-deletechar>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<deleteline>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<insertline>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-k") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-S-k") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-o") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "C-S-o") 'gro-key-disabled-feedback)

(define-key gro-mode-map (kbd "<M-insert>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<M-delete>") 'gro-key-disabled-feedback)

;; Inactivate keys that move point
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

(define-key gro-mode-map (kbd "<right>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<left>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<up>") 'gro-key-disabled-feedback)
(define-key gro-mode-map (kbd "<down>") 'gro-key-disabled-feedback)
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

;; Inactivate C-l (recenter-top-bottom)
;; to prevent changing buffer-line to a different window-line.
;; <http://www.masteringemacs.org/article/mastering-key-bindings-emacs>
(define-key gro-mode-map [remap recenter-top-bottom] 'gro-key-disabled-feedback)

;; Shortcut keys:
(define-key gro-mode-map (kbd "C-c C-f") 'gro-focus-toggle)
(define-key gro-mode-map (kbd "C-c C-c") 'gro-timestamp-insert)


;;; Global configuration

;; Upon starting gro-mode, move point to the end of the buffer.
;; (add-hook 'gro-mode-hook 'end-of-buffer) Docs say only use 'end-of-buffer interactively.
(add-hook 'gro-mode-hook (lambda () (goto-char (point-max))))

;; Files named *.gro open in gro-mode.
(add-to-list 'auto-mode-alist '("\\.gro\\'" . gro-mode))


(define-derived-mode gro-mode text-mode "gro"
  "Disallow most editing, except for inserting text.\n
Force the writer to continue \"freewriting\" without the ability to edit or revise.\n
Part of Elbow's process of \"growing\" writing.")


(provide 'gro)

;;; gro.el ends here
