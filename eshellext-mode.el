
;;; Code:

;; (make-variable-buffer-local
;;  (defvar eshellext-window nil
;;    "A reference to the window used to jump to files"))

;; (defun eshellext-get-window ()
;;   (when (not (bound-and-true-p eshellext-window))
;;     (setq eshellext-window split-window-below))
;; eshellext-window
;; )

; (defun insert-foo ()
;   (interactive)
;   (setq foo-count (1+ foo-count))
;   (insert "foo"))

(defun eshellext-goto-file (button)
  (find-file (concat default-directory (button-get button 'file-name)))
  (goto-char (point-min))
  (forward-line (1- (button-get button 'line)))
  (recenter))

(defun eshellext-buttonize (results)
  (dolist (elt results)
    (let ((file-name (car elt))
          (line (car (cdr elt)))
          (start (car (cdr (cdr elt))))
          (length (car (cdr (cdr (cdr elt))))))
      (when (file-exists-p (concat default-directory file-name))
        (let ((butt (make-button (+ 1 start) (+ 1 start length)
                                 'action 'eshellext-goto-file 'follow-link t)))
          (button-put butt 'file-name file-name)
          (button-put butt 'line line))))))

(defun eshellext-find-all-occurrences (str)
  (let* ((results (list))
         (last 0)
         (regex "\\([a-z]+\\.[a-z]+\\)#\\([0-9]+\\)")
         (temp (string-match regex str last)))
    (while temp
      (setq last temp)
      (let ((match-length (length (match-string 0 str))))
        (push (list
               (match-string 1 str)
               (string-to-number (match-string 2 str))
               last
               match-length)
              results)
        (setq temp (string-match regex str (+ last match-length)))))
    results))

; TODO optimise iteration

(defun eshellext-after-command ()
  (with-current-buffer "*eshell*"
    (dolist (oly (overlays-in (point-min) (point-max))) (delete-overlay oly))
    (eshellext-buttonize (eshellext-find-all-occurrences (buffer-string)))))

;;;###autoload
(define-minor-mode eshellext-mode
  "Extends Eshell with some useful stuff"
  :lighter " eshellext"
  :keymap (let ((map (make-sparse-keymap)))
            ;; (define-key map (kbd "C-c C-c") 'insert-foo)
            map)
  (add-hook 'eshell-post-command-hook 'eshellext-after-command))

(provide 'eshellext-mode)

;;; eshellext-mode.el ends here
