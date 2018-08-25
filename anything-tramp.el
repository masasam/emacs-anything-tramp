;;; anything-tramp.el --- Tramp with anything for ssh and docker and vagrant-*- lexical-binding: t; -*-

;; Copyright (C) 2017-2018 by Masashı Mıyaura

;; Author: Masashı Mıyaura
;; URL: https://github.com/masasam/emacs-anything-tramp
;; Version: 0.9.6
;; Package-Requires: ((emacs "24.3") (anything "1.0"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; anything-tramp provides interfaces of Tramp
;; You can also use tramp with anything interface as root
;; If you use it with docker-tramp, you can also use docker with anything interface
;; If you use it with vagrant-tramp, you can also use vagrant with anything interface

;;; Code:

(require 'anything)
(require 'tramp)
(require 'cl-lib)

(defgroup anything-tramp nil
  "Tramp with anything for ssh server and docker and vagrant"
  :group 'anything)

(defcustom anything-tramp-docker-user nil
  "If you want to use login user name when `docker-tramp' used, set variable."
  :group 'anything-tramp
  :type 'string)

(defcustom anything-tramp-localhost-directory "/"
  "Initial directory when connecting with /sudo:root@localhost:."
  :group 'anything-tramp
  :type 'string)

(defcustom anything-tramp-pre-command-hook nil
  "Hook run before `anything-tramp'.
The hook is called with one argument that is non-nil."
  :type 'hook)

(defcustom anything-tramp-post-command-hook nil
  "Hook run after `anything-tramp'.
The hook is called with one argument that is non-nil."
  :type 'hook)

(defcustom anything-tramp-quit-hook nil
  "Hook run when `anything-tramp-quit'.
The hook is called with one argument that is non-nil."
  :type 'hook)

(defun anything-tramp-quit ()
  "Quit anything-tramp.
Kill all remote buffers."
  (interactive)
  (run-hooks 'anything-tramp-quit-hook)
  (tramp-cleanup-all-buffers))

(defun anything-tramp--candidates ()
  "Collect candidates for anything-tramp."
  (let ((source (split-string
                 (with-temp-buffer
                   (insert-file-contents "~/.ssh/config")
                   (buffer-string))
                 "\n"))
        (hosts (list)))
    (dolist (host source)
      (when (string-match "[H\\|h]ost +\\(.+?\\)$" host)
	(setq host (match-string 1 host))
	(if (string-match "[ \t\n\r]+\\'" host)
	    (replace-match "" t t host))
	(if (string-match "\\`[ \t\n\r]+" host)
	    (replace-match "" t t host))
        (unless (string= host "*")
	  (if (string-match "[ ]+" host)
	      (let ((result (split-string host " ")))
		(while result
		  (push
		   (concat "/" tramp-default-method ":" (car result) ":")
		   hosts)
		  (push
		   (concat "/ssh:" (car result) "|sudo:root@" (car result) ":/")
		   hosts)
		  (pop result)))
	    (push
	     (concat "/" tramp-default-method ":" host ":")
	     hosts)
	    (push
	     (concat "/ssh:" host "|sudo:" host ":/")
	     hosts)))))
    (when (require 'docker-tramp nil t)
      (cl-loop for line in (cdr (ignore-errors (apply #'process-lines "docker" (list "ps"))))
	       for info = (reverse (split-string line "[[:space:]]+" t))
	       collect (progn (push
			       (concat "/docker:" (car info) ":/")
			       hosts)
			      (when anything-tramp-docker-user
				(if (listp anything-tramp-docker-user)
				    (let ((docker-user anything-tramp-docker-user))
				      (while docker-user
					(push
					 (concat "/docker:" (car docker-user) "@" (car info) ":/")
					 hosts)
					(pop docker-user)))
				  (push
				   (concat "/docker:" anything-tramp-docker-user "@" (car info) ":/")
				   hosts))))))
    (when (require 'vagrant-tramp nil t)
      (cl-loop for box-name in (map 'list 'cadr (vagrant-tramp--completions))
	       do (progn
		    (push (concat "/vagrant:" box-name ":/") hosts)
		    (push (concat "/vagrant:" box-name "|sudo:" box-name ":/") hosts))))
    (push (concat "/sudo:root@localhost:" anything-tramp-localhost-directory) hosts)
    (reverse hosts)))

(defun anything-tramp-open (path)
  "Tramp open with PATH."
  (find-file path))

(defvar anything-tramp-hosts
  '((name . "Tramp")
    (candidates . (lambda () (anything-tramp--candidates)))
    (type . file)
    (action . (("Tramp" . anything-tramp-open)))))

;;;###autoload
(defun anything-tramp ()
  "Open your ~/.ssh/config with anything interface.
You can connect your server with tramp"
  (interactive)
  (unless (file-exists-p "~/.ssh/config")
    (error "There is no ~/.ssh/config"))
  (when (require 'docker-tramp nil t)
    (unless (executable-find "docker")
      (error "'docker' is not installed")))
  (when (require 'vagrant-tramp nil t)
    (unless (executable-find "vagrant")
      (error "'vagrant' is not installed")))
  (run-hooks 'anything-tramp-pre-command-hook)
  (anything-other-buffer
   '(anything-tramp-hosts)
   "*anything-tramp*")
  (run-hooks 'anything-tramp-post-command-hook))

(provide 'anything-tramp)

;;; anything-tramp.el ends here
