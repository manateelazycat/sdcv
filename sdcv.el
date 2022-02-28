;;; sdcv.el --- Interface for sdcv (StartDict console version) -*- lexical-binding: t -*-

;; Filename: sdcv.el
;; Description: Interface for sdcv (StartDict console version).
;; Package-Requires: ((emacs "25.1") (posframe "1.1.2"))
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2009, Andy Stewart, all rights reserved.
;; Created: 2009-02-05 22:04:02
;; Version: 3.4
;; Last-Updated: 2020-06-12 19:32:08
;;           By: Andy Stewart
;; URL: http://www.emacswiki.org/emacs/download/sdcv.el
;; Keywords: docs, startdict, sdcv
;; Compatibility: GNU Emacs 25.1
;;
;; Features that might be required by this library:
;;
;; `posframe' `outline'
;;

;;; This file is NOT part of GNU Emacs

;;; License
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; Interface for sdcv (StartDict console version).
;;
;; Translate word by sdcv (console version of Stardict), and display
;; translation using posframe or in buffer.
;;
;; Below are commands you can use:
;;
;; `sdcv-search-pointer'
;; Search around word and display in buffer.
;; `sdcv-search-pointer+'
;; Search around word and display with `posframe'.
;; `sdcv-search-input'
;; Search input word and display in buffer.
;; `sdcv-search-input+'
;; Search input word and display with `posframe'.
;;
;; Tips:
;;
;; If current mark is active, sdcv commands will translate
;; contents in region, otherwise translate word at point.
;;

;;; Installation:
;;
;; To use this extension, you have to install Stardict and sdcv
;; If you use Debian, it's simple, just:
;;
;;      sudo aptitude install stardict sdcv -y
;;
;; And make sure you have installed `posframe.el'.
;; You can get it from:
;; https://raw.githubusercontent.com/tumashu/posframe/master/posframe.el
;;
;; Put sdcv.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'sdcv)
;;
;; And then you need to set two options.
;;
;;  sdcv-dictionary-simple-list         (a simple dictionary list for posframe display)
;;  sdcv-dictionary-complete-list       (a complete dictionary list for buffer display)
;;
;; Example, setup like this:
;;
;; (setq sdcv-dictionary-simple-list (list "懒虫简明英汉词典"
;;                                         "懒虫简明汉英词典"
;;                                         "KDic11万英汉词典")
;;       sdcv-dictionary-complete-list (list "KDic11万英汉词典"
;;                                           "懒虫简明英汉词典"
;;                                           "朗道英汉字典5.0"
;;                                           "XDICT英汉辞典"
;;                                           "朗道汉英字典5.0"
;;                                           "XDICT汉英辞典"
;;                                           "懒虫简明汉英词典"
;;                                           "牛津英汉双解美化版"
;;                                           "stardict1.3英汉辞典"
;;                                           "英汉汉英专业词典"
;;                                           "CDICT5英汉辞典"
;;                                           "Jargon"
;;                                           "FOLDOC"
;;                                           "WordNet")
;;       sdcv-dictionary-data-dir "your_sdcv_dict_dir") ; set local sdcv dict dir

;;; Customize:
;;
;; `sdcv-buffer-name'
;; The name of sdcv buffer.
;;
;; `sdcv-dictionary-simple-list'
;; The dictionary list for simple description.
;;
;; `sdcv-dictionary-complete-list'
;; The dictionary list for complete description.
;;
;; `sdcv-dictionary-data-dir'
;; The directory where stardict dictionaries are stored.
;;
;; `sdcv-tooltip-face'
;; The foreground/background colors of sdcv tooltip.
;;
;; All of the above can customize by:
;;      M-x customize-group RET sdcv RET
;;

;;; Change log:
;;
;; 2020/06/12
;;      * Add `sdcv-env-lang' option.
;;
;; 2020/02/13
;;      * Support EAF mode and don't jump pointer when sdcv frame popup.
;;
;; 2019/09/30
;;      * Use `zh_CN.UTF-8' instead `en_US.UTF-8' to fixed dictionary name issue.
;;
;; 2019/04/12
;;      * Use `split-string' instead `s-split' to remove depend of s.el
;;
;; 2019/04/05
;;      * Add -x option avoid read dict from env `STARDICT_DATA_DIR'.
;;
;; 2019/02/20
;;      * Try pick word from camelcase string and translate again if no translate result for current string.
;;
;; 2018/12/09
;;      * Add command `sdcv-check' to help check invalid dictionaries.
;;
;; 2018/09/10
;;      * Add option `sdcv-say-word-p', just support OSX now, please send me PR if you want to support Linux. ;)
;;      * Make `sdcv-say-word' can work with `sdcv-search-pointer'.
;;      * Make `sdcv-say-word' support all platform.
;;      * Don't need `osx-lib' anymore.
;;
;; 2018/07/16
;;      * Fixed typo that uncomment setenv code.
;;
;; 2018/07/08
;;      * Add new option `sdcv-tooltip-border-width'.
;;
;; 2018/07/05
;;      * Use `posframe' for MacOS, bug has fixed at: https://www.emacswiki.org/emacs/init-startup.el
;;
;; 2018/07/01
;;      * Add support for MacOS, use `popup-tip'.
;;
;; 2018/06/23
;;      * Set LANG environment variable, make sure `shell-command-to-string' can handle CJK character correctly.
;;
;; 2018/06/20
;;      * Add `sdcv-dictionary-data-dir'
;;      * Use `posframe' instead `showtip' for better user experience.
;;      * Add new face `sdcv-tooltip-face' for customize.
;;      * Automatically hide sdcv tooltip once user move cursor of scroll window.
;;      * Make sure sdcv tooltip buffer kill after frame deleted.
;;      * Improve function `sdcv-hide-tooltip-after-move' performance.
;;      * Show tooltip above minibuffer if word is input from user.
;;
;; 2009/04/04
;;      * Fix the bug of `sdcv-search-pointer'.
;;      * Fix doc.
;;        Thanks "Santiago Mejia" report those problems.
;;
;; 2009/04/02
;;      * Remove unnecessary information from transform result.
;;
;; 2009/03/04
;;      * Refactory code.
;;      * Search region or word around point.
;;      * Fix doc.
;;
;; 2009/02/05
;;      * Fix doc.
;;
;; 2008/06/01
;;      * First released.
;;

;;; Acknowledgements:
;;
;;      pluskid@gmail.com   (Zhang ChiYuan)     for sdcv-mode.el
;;

;;; Require

(require 'json)
(require 'subr-x)
(require 'outline)
(require 'subword)

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Customize ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defgroup sdcv nil
  "Interface for sdcv (StartDict console version)."
  :group 'edit)

(defcustom sdcv-buffer-name "*SDCV*"
  "The name of the sdcv buffer."
  :type 'string
  :group 'sdcv)

(defcustom sdcv-tooltip-name "*sdcv*"
  "The name of sdcv tooltip name."
  :type 'string
  :group 'sdcv)

(defcustom sdcv-program (if (string-equal system-type "darwin") "/usr/local/bin/sdcv" "sdcv")
  "Path to sdcv."
  :type 'file
  :group 'sdcv)

(defcustom sdcv-tooltip-timeout 5
  "The timeout for sdcv tooltip, in seconds."
  :type 'integer
  :group 'sdcv)

(defcustom sdcv-dictionary-complete-list nil
  "The complete dictionary list for translation."
  :type 'list
  :group 'sdcv)

(defcustom sdcv-dictionary-simple-list nil
  "The simple dictionary list for translation."
  :type 'list
  :group 'sdcv)

(defcustom sdcv-dictionary-data-dir nil
  "Default, sdcv search word in /usr/share/startdict/dict/.
If you customize this value with local dir, then you don't need
to copy dict data to /usr/share directory everytime when you
finish system installation."
  :type '(choice (const :tag "Default" nil) directory)
  :group 'sdcv)

(defcustom sdcv-only-data-dir t
  "Search is performed using only `sdcv-dictionary-data-dir'."
  :type 'boolean
  :group 'sdcv)

(defcustom sdcv-tooltip-border-width 10
  "The border width of sdcv tooltip, in pixels."
  :type 'integer
  :group 'sdcv)

(defcustom sdcv-say-word-p nil
  "Say word after searching if this option is non-nil.

It will use system feature if you use OSX, otherwise youdao.com."
  :type 'boolean
  :group 'sdcv)

(defcustom sdcv-env-lang "zh_CN.UTF-8"
  "Default LANG environment for sdcv program.

Default is zh_CN.UTF-8, maybe you need to change it to other
coding if your system is not zh_CN.UTF-8."
  :type 'string
  :group 'sdcv)

(defface sdcv-tooltip-face
  '((t (:foreground "green" :background "gray12")))
  "Face for sdcv tooltip"
  :group 'sdcv)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Variable ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar sdcv-previous-window-configuration nil
  "Window configuration before switching to sdcv buffer.")

(defvar sdcv-current-translate-object nil
  "The search object.")

(defvar sdcv-fail-notify-string "没有发现解释也... \n用更多的词典查询一下吧! ^_^"
  "User notification message on failed search.")

(defvar sdcv-mode-font-lock-keywords
  '(;; Dictionary name
    ("^-->\\(.*\\)\n-" . (1 font-lock-type-face))
    ;; Search word
    ("^-->\\(.*\\)[ \t\n]*" . (1 font-lock-function-name-face))
    ;; Serial number
    ("\\(^[0-9] \\|[0-9]+:\\|[0-9]+\\.\\)" . (1 font-lock-constant-face))
    ;; Type name
    ("^<<\\([^>]*\\)>>$" . (1 font-lock-comment-face))
    ;; Phonetic symbol
    ("^/\\([^>]*\\)/$" . (1 font-lock-string-face))
    ("^\\[\\([^]]*\\)\\]$" . (1 font-lock-string-face)))
  "Expressions to highlight in `sdcv-mode'.")

(easy-mmode-defmap sdcv-mode-map
  '(;; Sdcv command.
    ("q" . sdcv-quit)
    ("j" . sdcv-next-line)
    ("k" . sdcv-prev-line)
    ("J" . sdcv-scroll-up-one-line)
    ("K" . sdcv-scroll-down-one-line)
    ("d" . sdcv-next-dictionary)
    ("f" . sdcv-previous-dictionary)
    ("i" . sdcv-search-input)
    (";" . sdcv-search-input+)
    ("p" . sdcv-search-pointer)
    ("y" . sdcv-search-pointer+)
    ;; Isearch.
    ("S" . isearch-forward-regexp)
    ("R" . isearch-backward-regexp)
    ("s" . isearch-forward)
    ("r" . isearch-backward)
    ;; Hideshow.
    ("a" . outline-show-all)
    ("A" . outline-hide-body)
    ("v" . outline-show-entry)
    ("V" . outline-hide-entry)
    ;; Misc.
    ("e" . scroll-down)
    (" " . scroll-up)
    ("l" . forward-char)
    ("h" . backward-char)
    ("?" . describe-mode))
  "Keymap for `sdcv-mode'.")

(define-derived-mode sdcv-mode nil "sdcv"
  "Major mode to look up word through sdcv.
\\{sdcv-mode-map}

Turning on Text mode runs the normal hook `sdcv-mode-hook'."
  (setq font-lock-defaults '(sdcv-mode-font-lock-keywords t))
  (setq buffer-read-only t)
  (set (make-local-variable 'outline-regexp) "^-->.*\n-->"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Interactive Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;###autoload
(defun sdcv-search-pointer (&optional word)
  "Get current WORD.
Display complete translations in other buffer."
  (interactive)
  ;; Display details translate result
  (sdcv-search-detail (or word (sdcv-region-or-word))))

;;;###autoload
(defun sdcv-search-pointer+ ()
  "Translate word at point.
Show information using tooltip.  This command uses
`sdcv-dictionary-simple-list'."
  (interactive)
  ;; Display simple translate result.
  (sdcv-search-simple))

;;;###autoload
(defun sdcv-search-input (&optional word)
  "Translate current input WORD.
And show information in other buffer."
  (interactive)
  ;; Display details translate result.
  (sdcv-search-detail (or word (sdcv-prompt-input))))

;;;###autoload
(defun sdcv-search-input+ (&optional word)
  "Translate current WORD at point.
And show information using tooltip."
  (interactive)
  ;; Display simple translate result.
  (sdcv-search-simple (or word (sdcv-prompt-input))))

(defun sdcv-quit ()
  "Bury sdcv buffer and restore previous window configuration."
  (interactive)
  (if (window-configuration-p sdcv-previous-window-configuration)
      (progn
        (set-window-configuration sdcv-previous-window-configuration)
        (setq sdcv-previous-window-configuration nil)
        (bury-buffer (sdcv-get-buffer)))
    (bury-buffer)))

(defun sdcv-next-dictionary ()
  "Jump to next dictionary."
  (interactive)
  (outline-show-all)
  (if (search-forward-regexp "^-->.*\n-" nil t) ;don't show error when search failed
      (progn
        (call-interactively 'previous-line)
        (recenter 0))
    (message "Reached last dictionary.")))

(defun sdcv-previous-dictionary ()
  "Jump to previous dictionary."
  (interactive)
  (outline-show-all)
  (if (search-backward-regexp "^-->.*\n-" nil t) ;don't show error when search failed
      (progn
        (forward-char 1)
        (recenter 0))                   ;adjust position
    (message "Reached first dictionary.")))

(defun sdcv-scroll-up-one-line ()
  "Scroll up one line."
  (interactive)
  (scroll-up 1))

(defun sdcv-scroll-down-one-line ()
  "Scroll down one line."
  (interactive)
  (scroll-down 1))

(defun sdcv-next-line (arg)
  "Go to next ARGth line and show item."
  (interactive "P")
  (ignore-errors
    (call-interactively 'next-line arg)
    (save-excursion
      (beginning-of-line nil)
      (when (looking-at outline-regexp)
        (outline-show-entry)))))

(defun sdcv-prev-line (arg)
  "Go to previous ARGth line."
  (interactive "P")
  (ignore-errors
    (call-interactively 'previous-line arg)))

(defun sdcv-check ()
  "Check for missing StarDict dictionaries."
  (interactive)
  (let* ((dicts (sdcv-list-dicts))
         (missing-simple-dicts (sdcv-missing-dicts sdcv-dictionary-simple-list dicts))
         (missing-complete-dicts (sdcv-missing-dicts sdcv-dictionary-complete-list dicts)))
    (if (not (or missing-simple-dicts missing-complete-dicts))
        (message "The dictionary's settings look correct, sdcv should work as expected.")
      (dolist (dict missing-simple-dicts)
        (message "sdcv-dictionary-simple-list: dictionary '%s' does not exist, remove it or download the corresponding dictionary file to %s"
                 dict sdcv-dictionary-data-dir))
      (dolist (dict missing-complete-dicts)
        (message "sdcv-dictionary-complete-list: dictionary '%s' does not exist, remove it or download the corresponding dictionary file to %s"
                 dict sdcv-dictionary-data-dir)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Utilities Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun sdcv-call-process (&rest arguments)
  "Call `sdcv-program' with ARGUMENTS.
Result is parsed as json."
  (with-temp-buffer
    (save-excursion
      (let* ((lang-env (concat "LANG=" sdcv-env-lang))
             (process-environment (cons lang-env process-environment)))
        (apply #'call-process sdcv-program nil t nil
               (append (list "--non-interactive" "--json-output")
                       (when sdcv-only-data-dir
                         (list "--only-data-dir"))
                       (when sdcv-dictionary-data-dir
                         (list "--data-dir" sdcv-dictionary-data-dir))
                       arguments))))
    (ignore-errors (json-read))))

(defun sdcv-list-dicts ()
  "List dictionaries present in SDCV."
  (mapcar (lambda (dict) (cdr (assq 'name dict)))
          (sdcv-call-process "--list-dicts")))

(defun sdcv-missing-dicts (list &optional dicts)
  "List missing LIST dictionaries in DICTS.
If DICTS is nil, compute present dictionaries with
`sdcv--list-dicts'."
  (let ((dicts (or dicts (sdcv-list-dicts))))
    (cl-set-difference list dicts :test #'string=)))

(defun sdcv-search-detail (&optional word)
  "Search WORD in `sdcv-dictionary-complete-list'.
The result will be displayed in buffer named with
`sdcv-buffer-name' in `sdcv-mode'."
  (message "Searching...")
  (with-current-buffer (get-buffer-create sdcv-buffer-name)
    (setq buffer-read-only nil)
    (erase-buffer)
    (setq sdcv-current-translate-object word)
    (insert (sdcv-search-with-dictionary word sdcv-dictionary-complete-list))
    (sdcv-goto-sdcv)
    (sdcv-mode-reinit)))

(defun sdcv-search-simple (&optional word)
  "Search WORD simple translate result."
  (when (ignore-errors (require 'posframe))
    (let ((result (sdcv-search-with-dictionary word sdcv-dictionary-simple-list)))
      ;; Show tooltip at point if word fetch from user cursor.
      (posframe-show
       sdcv-tooltip-name
       :string result
       :position (if (derived-mode-p 'eaf-mode) (mouse-absolute-pixel-position) (point))
       :timeout sdcv-tooltip-timeout
       :background-color (face-attribute 'sdcv-tooltip-face :background)
       :foreground-color (face-attribute 'sdcv-tooltip-face :foreground)
       :internal-border-width sdcv-tooltip-border-width
       :tab-line-height 0
       :header-line-height 0)
      (unwind-protect
          (push (read-event " ") unread-command-events)
        (posframe-delete sdcv-tooltip-name)))))

(defun sdcv-say-word (word)
  "Listen to WORD pronunciation."
  (if (featurep 'cocoa)
      (call-process-shell-command
       (format "say %s" word) nil 0)
    (let ((player (or (executable-find "mpv")
                      (executable-find "mplayer")
                      (executable-find "mpg123"))))
      (if player
          (start-process
           player
           nil
           player
           (format "http://dict.youdao.com/dictvoice?type=2&audio=%s" (url-hexify-string word)))
        (message "mpv, mplayer or mpg123 is needed to play word voice")))))

(defun sdcv-search-with-dictionary (word dictionary-list)
  "Search some WORD with DICTIONARY-LIST.
Argument DICTIONARY-LIST the word that needs to be transformed."
  (let* ((word (or word (sdcv-region-or-word)))
         (translate-result (sdcv-translate-result word dictionary-list)))

    (when (and (string= sdcv-fail-notify-string translate-result)
               (setq word (sdcv-pick-word)))
      (setq translate-result (sdcv-translate-result word dictionary-list)))

    (when sdcv-say-word-p
      (sdcv-say-word word))

    translate-result))

(defun sdcv-pick-word (&optional _str)
  "Pick word from camelcase string at point.
_STR is ignored and leaved for backwards compatibility."
  (let ((subword (make-symbol "subword")))
    (put subword 'forward-op 'subword-forward)
    (thing-at-point subword t)))

(defun sdcv-translate-result (word dictionary-list)
  "Call sdcv to search WORD in DICTIONARY-LIST.
Return filtered string of results."
  (let* ((arguments (cons word (mapcan (lambda (d) (list "-u" d)) dictionary-list)))
         (result (mapconcat
                  (lambda (result)
                    (let-alist result
                      (format "-->%s\n-->%s\n%s\n\n" .dict .word .definition)))
                  (apply #'sdcv-call-process arguments)
                  "")))
    (if (string-empty-p result)
        sdcv-fail-notify-string
      result)))

(defun sdcv-goto-sdcv ()
  "Switch to sdcv buffer in other window."
  (setq sdcv-previous-window-configuration (current-window-configuration))
  (let* ((buffer (sdcv-get-buffer))
         (window (get-buffer-window buffer)))
    (if (null window)
        (switch-to-buffer-other-window buffer)
      (select-window window))))

(defun sdcv-get-buffer ()
  "Get the sdcv buffer.  Create one if there's none."
  (let ((buffer (get-buffer-create sdcv-buffer-name)))
    (with-current-buffer buffer
      (unless (eq major-mode 'sdcv-mode)
        (sdcv-mode)))
    buffer))

(defvar sdcv-mode-reinit-hook 'nil
  "Hook for `sdcv-mode-reinit'.
This hook is called after `sdcv-search-detail'.")

(defun sdcv-mode-reinit ()
  "Re-initialize buffer.
Hide all entry but the first one and goto
the beginning of the buffer."
  (ignore-errors
    (setq buffer-read-only t)
    (goto-char (point-min))
    (sdcv-next-dictionary)
    (outline-show-all)
    (run-hooks 'sdcv-mode-reinit-hook)
    (message "Finished searching `%s'." sdcv-current-translate-object)))

(defun sdcv-prompt-input ()
  "Prompt input for translation."
  (let* ((word (sdcv-region-or-word))
         (default (if word (format " (default %s)" word) "")))
    (read-string (format "Word%s: " default) nil nil word)))

(defun sdcv-region-or-word ()
  "Return region or word around point.
If `mark-active' on, return region string.
Otherwise return word around point."
  (if (use-region-p)
      (buffer-substring-no-properties (region-beginning) (region-end))
    (thing-at-point 'word t)))


(provide 'sdcv)

;;; sdcv.el ends here

;;; LocalWords:  sdcv StartDict startdict posframe stardict KDic XDICT CDICT
;;; LocalWords:  FOLDOC WordNet ChiYuan Hideshow reinit
