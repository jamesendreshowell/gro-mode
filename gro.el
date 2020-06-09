;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; gro-mode
;; 
;; Inspired by Elbow's (_Writing Without Teachers_, 1973) distinction
;; between "growing" vs. "cooking" writing.
;;
;; https://en.wikipedia.org/wiki/Peter_Elbow#Writing_Without_Teachers
;;
;; A major mode for "freewriting," for simply getting text out of your
;; head without reflection or self-censorship.
;;
;; Named for the use of freewriting in the process of "growing"
;; writing. Also named in (backwards) homage to Org-mode, which works
;; very well for "cooking" writing.

(defun gro-insert-nothing ()
  "Insert an unwanted character to provide feedback that editing keys are disabled in gro-mode."
  (interactive)
  (message "Growing!")
  (insert "* "))

(defvar gro-date-time-format
  "%A %Y %B %d %R"
  "See help of `format-time-string' for possible values.")

(defun gro-insert-timestamp ()
  "Insert timestamp, like for a running journal."
  (interactive)
  (insert (concat "\n\n" (format-time-string gro-date-time-format (current-time)) "\n")))

(defvar gro-mode-map nil "Keymap for gro-mode")
(setq gro-mode-map (make-sparse-keymap))

(define-key gro-mode-map (kbd "C-c C-c") 'gro-insert-timestamp)

(define-key gro-mode-map (kbd "M-<") 'gro-insert-nothing)
(define-key gro-mode-map (kbd "M->") 'gro-insert-nothing)
(define-key gro-mode-map (kbd "C-a") 'gro-insert-nothing)
(define-key gro-mode-map (kbd "C-e") 'gro-insert-nothing)
(define-key gro-mode-map (kbd "C-f") 'gro-insert-nothing)
(define-key gro-mode-map (kbd "C-b") 'gro-insert-nothing)
(define-key gro-mode-map (kbd "C-p") 'gro-insert-nothing)
(define-key gro-mode-map (kbd "C-n") 'gro-insert-nothing)
(define-key gro-mode-map (kbd "<right>") 'gro-insert-nothing)
(define-key gro-mode-map (kbd "<left>") 'gro-insert-nothing)
(define-key gro-mode-map (kbd "<up>") 'gro-insert-nothing)
(define-key gro-mode-map (kbd "<down>") 'gro-insert-nothing)
(define-key gro-mode-map (kbd "<backspace>") 'gro-insert-nothing)
(define-key gro-mode-map (kbd "<deletechar>") 'gro-insert-nothing)

(define-derived-mode gro-mode text-mode "gro"
  "Disallow most editing, except for inserting text.\n
Force the writer to continue \"freewriting\" without the ability to edit or revise.\n
Part of Elbow's process of \"growing\" writing.\n
\n
\{gro-mode-map}"
)

;;; Files named *.gro will open in gro-mode.
(add-to-list 'auto-mode-alist '("\\.gro\\'" . gro-mode))

;;; Upon starting gro-mode, move point to the end of the buffer.
;;; E.g. for revisiting a file containing a notebook or journal
;;; of freewriting. In gro-mode moving point is disabled!
(add-hook 'gro-mode-hook 'end-of-buffer)

(provide 'gro)
