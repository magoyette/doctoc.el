;;; doctoc.el --- Support for DocToc in Emacs.

;; Copyright (C) 2016 Marc-André Goyette
;; Author: Marc-André Goyette <goyette.marcandre@gmail.com>
;; URL: https://github.com/magoyette/doctoc.el
;; Version: 0.1.0
;; Package-Requires: ((emacs "25"))
;; Keywords: markdown

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; doctoc.el provides functions for DocToc (https://github.com/thlorenz/doctoc),
;; a JavaScript library that generates a table of contents for markdown files.

;; The doctoc function allows to call DocToc on the file of the current buffer.
;; It can be associated to a keybinding:

;;    (define-key markdown-mode-map (kbd "C-c C-d") #'doctoc)

;; The doctoc-insert-toc-comment function allows to insert HTML comments that
;; indicate to DocToc where the table of contents should be generated in a file.

;;; Code:

(defgroup doctoc nil
  "Generate the table of contents of a Markdown file with DocToc."
  :group 'markdown
  :prefix "doctoc-")

(defcustom doctoc-bin "doctoc"
  "Path to markdownfmt executable."
  :type 'string
  :group 'doctoc)

(defcustom doctoc-keep-all-output nil
  "Configure the *DocToc* buffer to keep the output of all the calls to DocToc.
By default, only the output to the last call to DocToc is kept, to prevent the
*DocToc* buffer from becoming too large."
  :type 'boolean
  :group 'doctoc)

(defun doctoc--erase-doctoc-buffer ()
  "Erase the previous contents of the DocToc buffer."
  (with-current-buffer (get-buffer-create "*DocToc*")
    (erase-buffer)))

(defun doctoc--call-doctoc-process ()
  "Call the DocToc executable on the file of the current buffer."
  (call-process doctoc-bin nil "*DocToc*" nil buffer-file-name))

(defun doctoc--handle-error-from-process ()
  "Print an error message when the DocToc process return an error."
  (error "DocToc failed, see the *DocToc* buffer for details"))

(defun doctoc--handle-missing-doctoc-executable ()
  "Print an error when the DocToc executable cannot be found."
  (error (format "%s executable not found." doctoc-bin)))

;;;###autoload
(defun doctoc ()
  "Generate the table of contents of the current file with DocToc."
  (interactive)
  (if (executable-find doctoc-bin)
      (progn
        (unless doctoc-keep-all-output (doctoc--erase-doctoc-buffer))
        (save-buffer)
        (let ((success (zerop (doctoc--call-doctoc-process))))
          (revert-buffer t t t)
          (unless success (doctoc--handle-error-from-process))))
    (doctoc--handle-missing-doctoc-executable)))

;;;###autoload
(defun doctoc-insert-toc-comment ()
  "Insert a comment to indicate the location of the table of contents."
  (interactive)
  (insert "<!-- START doctoc -->
<!-- END doctoc -->"))

(provide 'doctoc)
;;; doctoc.el ends here
