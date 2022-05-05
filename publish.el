;;; publish.el --- Build and Org blog -*- lexical-binding: t -*-

;; Copyright (C) 2022 pek <me@pek.mk>

;; Author: pek <me@pek.mk>
;; Maintainer: pek <me@pek.mk>
;; URL: https://git.sr.ht/~heph/blog.pek.mk
;; Version: 0.0.1
;; Package-Requires: ((emacs "26.1"))
;; Keywords: hypermedia, blog, feed, rss

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

;; Org publish
(require 'ox-publish)

;; RSS feeds
;;(require 'webfeeder)

;; Highlighting of languages
;;(require 'htmlize)

(defvar pek-html-preamble
"<header>
  <nav>
   <ul>
    <li><a href=\"/\">~/pek</a></li> /
    <li><a href=\"/contact.html\">Contact</a></li> /
    <li><a href=\"/blog/index.html\">Blog</a></li>
   </ul>
  </nav>
</header>"
)

(defun pek/org-publish-blog-index (title list)
  "My blog index generator, takes TITLE and LIST of files to make to a string."
  (let ((filtered-list '()))
    ;; Loop through all list items
    (dolist (item list)
      (unless (eq item 'unordered)
        (let ((file (car item)))
          ;; Remove index and non blog posts
          (unless (or (string-match "file:index.org" file)
                      (string-match "file:about/index.org" file)
                      (string-match "file:drafts/" file)
                      (string-match "file:talks/index.org" file)
                      (string-match "file:work/index.org" file))

            (let ((dir (replace-regexp-in-string "index.org" "" file)))
              ;; Rewrite file: to file:../
              (push (list (replace-regexp-in-string "file:" "file:./" dir))
                    filtered-list))))))

    ;; Fix up the list before sending it to `org-list-to-org'.
    (let ((fixed-list (cons 'unordered filtered-list)))
      ;; Build string
      (concat "#+SETUPFILE: ../../org-templates/metadata.org\n"
              "#+TITLE: " title "\n"
              "\n\n"
              (org-list-to-org fixed-list)))))

; Configure org to not put timestamps in the home directory since that breaks
;; nix-build of the project due to sandboxing.
(setq org-publish-timestamp-directory "./.org-timestamps/")

;; Disable the validation links in the footers.
(setq org-html-validation-link nil)

;; Don't inline the css for the color highlight in the output
(setq org-html-htmlize-output-type "css")

(setq org-publish-project-alist
      `(("pages"
	 :base-directory "~/env/blog/src/"
	 :base-extension "org"
	 :recursive t
	 :publishing-directory "~/env/blog/public/"
	 :publishing-function org-html-publish-to-html
	 :with-toc nil
	 :html-head nil
	 :html-preamble , pek-html-preamble)

	("blog"
	 :base-directory "~/env/blog/src/blog/"
	 :base-extension "org"
	 :publishing-directory "~/env/blog/public/blog"
	 :publishing-function org-html-publish-to-html
	 :org-html-preamble t
	 :auto-sitemap t
	 :sitemap-title "Blog"
	 :sitemap-filename "index.org"
	 :sitemap-style list
	 :sitemap-sort-files chronologically
	 :sitemap-function pek/org-publish-blog-index
	 :html-preamble , pek-html-preamble)

	("static"
	 :base-directory "~/env/blog/src/"
	 :base-extension "css\\|txt\\|jpg\\|gif\\|png"
	 :recursive t
	 :publishing-directory "~/env/blog/public/"
	 :publishing-function org-publish-attachment)

	("pek.mk" :components ("pages" "blog" "static"))))

(org-publish "pek.mk")
;;; publish.el ends here
