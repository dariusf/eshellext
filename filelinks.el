
;;; Code:

(defvar filelinks-directory ""
  "The directory to find files in.")

(defvar filelinks-overlays ()
  "A list of all the overlays created by this plugin.")

(defun filelinks-goto-file (button)
  (find-file (concat filelinks-directory (button-get button 'file-name)))
  (goto-char (point-min))
  (forward-line (1- (button-get button 'line)))
  (recenter))

(defun filelinks-buttonize (results)
  (dolist (elt results)
    (let ((file-name (nth 0 elt))
          (line (nth 1 elt))
          (start (nth 2 elt))
          (length (nth 3 elt)))
      (when (file-exists-p (concat filelinks-directory file-name))
        (let ((butt (make-button (+ 1 start) (+ 1 start length)
                                 'action 'filelinks-goto-file 'follow-link t)))
          (button-put butt 'file-name file-name)
          (button-put butt 'line line)
          (push butt filelinks-overlays))))))

(defun filelinks-find-all-occurrences (str)
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

(defun filelinks-delete-buttons ()
    (mapc 'delete-overlay filelinks-overlays)
    (setq filelinks-overlays ()))

(defun filelinks-create-buttons ()
  (filelinks-delete-buttons)
  (filelinks-buttonize (filelinks-find-all-occurrences (buffer-string))))

(defun filelinks-show (directory)
  (interactive (list
                (read-directory-name "Directory? "
                                     (or (buffer-file-name)
                                         default-directory)
                                     nil t filelinks-directory)))
  (setq filelinks-directory directory)
  (filelinks-create-buttons))

(defun filelinks-hide ()
  (interactive)
  (filelinks-delete-buttons))

(provide 'filelinks)

;;; filelinks.el ends here
