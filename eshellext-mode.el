
;;; Code:

(require 'filelinks)

(defun eshellext-after-command ()
  (with-current-buffer "*eshell*"
    (filelinks-show (buffer-file-name))))

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
