

;; several parts of this script are copied from Rasmus' publish.el
;; and Nicolas Petton's setup

;; run with
;;; bash publish.sh [t]
;; or
;;; emacs --batch --no-init-file --load publish.el --eval '(org-publish-all t)'

;; (package-initialize)

(require 'htmlize)
(require 'ox-html)

;; Customize the HTML output
(setq org-html-validation-link nil ;; Don't show validation link
      org-html-head-include-scripts nil       ;; Use our own scripts
      org-html-head-include-default-style nil ;; Use our own styles
      org-html-head "<link rel=\"stylesheet\" href=\"static/site.css\" />")

(setq org-export-with-smart-quotes t)

(setq org-html-divs '((preamble "header" "top")
                      (content "main" "content")
                      (postamble "footer" "postamble"))
      org-html-container-element "section"
      org-html-metadata-timestamp-format "%Y-%m-%d"
      org-html-checkbox-type 'html
      org-html-html5-fancy t
      org-html-validation-link nil
      org-html-doctype "html5")


(defvar bruno-website-html-head
  "<link rel='stylesheet' href='/static/site.css' type='text/css'/>
<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">
<link rel='icon' type='image/x-icon' href='/static/favicon.ico'/>")

(defvar bruno-website-html-blog-head bruno-website-html-head)

(defvar bruno-website-html-preamble
  "<div class='nav'>
<ul>
<li><a href='/'>home</a></li>
<li><a href='/research-log/index.html'>research log</a></li>
<li><a href='/blog/index.html'>personal blog</a></li>
<li><a href='https://github.com/odanoburu'>github</a></li>
<!-- <li><a href='/page/publications.html'>publications</a></li> -->
<li><a href='/page/about.html'>about</a></li>
</ul>
</div>")

(defvar bruno-website-html-postamble "")

(defvar base-dir (file-name-directory (or load-file-name buffer-file-name)))
(defvar publish-dir (file-name-as-directory (concat base-dir "public")))
(defvar static-dir (file-name-as-directory (concat publish-dir "static")))

(defvar bruno-website-with-creator nil)

(setq org-publish-project-alist
      (list
       (list "org"
	     :base-directory base-dir
	     :base-extension "org"
	     :publishing-directory publish-dir
	     :publishing-function #'org-html-publish-to-html
	     :section-numbers nil
	     :with-toc nil
	     :recursive nil
	     :with-author nil ;; Don't include author name
	     :with-creator bruno-website-with-creator
	     :time-stamp-file nil
	     :html-head bruno-website-html-head
	     :html-postamble bruno-website-html-postamble
	     :completion-function (lambda (ps)
				    (let* ((robots-file (concat (plist-get ps :base-directory) "robots.txt"))
					   (publish-dir (plist-get ps :publishing-directory))
					   (root-robots-file (concat publish-dir "robots.txt")))
				      (message root-robots-file)
				      (copy-file robots-file root-robots-file t))))

       (list "pages"
	     :exclude "publications.org"
	     :base-directory (concat base-dir "page/")
	     :base-extension "org"
	     :publishing-directory (concat publish-dir "page/")
	     :publishing-function #'org-html-publish-to-html
	     :section-numbers nil
	     :with-toc nil
	     :recursive t
	     :with-author nil ;; Don't include author name
	     :with-creator bruno-website-with-creator
	     :html-head bruno-website-html-head
	     :html-preamble bruno-website-html-preamble
	     :html-postamble bruno-website-html-postamble)

       (list "rlog"
	     :base-directory (concat base-dir "research-log/")
	     :base-extension "org"
	     :publishing-directory (concat publish-dir "research-log/")
	     :publishing-function #'org-html-publish-to-html
	     :section-numbers t
	     :with-toc t
	     :with-author nil ;; Don't include author name
	     :with-creator bruno-website-with-creator
	     ;; :auto-sitemap t
	     ;; :sitemap-style 'list
	     ;; :sitemap-title "sitemap for bruno's research log"
	     :recursive t
	     ;; :sitemap-filename "index.org"
	     ;; :sitemap-file-entry-format "%d *%t*"
	     ;; :sitemap-sort-files 'anti-chronologically
	     :html-head bruno-website-html-blog-head
	     :html-preamble bruno-website-html-preamble
	     :html-postamble bruno-website-html-postamble)

       (list "blog"
	     :base-directory (concat base-dir "blog/")
	     :base-extension "org"
	     :publishing-directory (concat publish-dir "blog/")
	     :publishing-function #'org-html-publish-to-html
	     :section-numbers nil
	     :with-toc nil
	     :with-author nil ;; Don't include author name
	     :with-creator bruno-website-with-creator
	     ;; :auto-sitemap nil
	     ;; :sitemap-title "sitemap for bruno's personal blog"
	     :recursive t
	     ;; :sitemap-filename "index.org"
	     ;; :sitemap-file-entry-format "%d *%t*"
	     ;; :sitemap-style 'list
	     ;; :sitemap-sort-files 'anti-chronologically
	     :html-head bruno-website-html-blog-head
	     :html-preamble bruno-website-html-preamble
	     :html-postamble bruno-website-html-postamble)

       (list "images"
	     :base-directory (concat base-dir "images/")
	     :base-extension (regexp-opt (list "jpg" "gif" "png" "ico" "svg"))
	     :publishing-directory static-dir
	     :publishing-function #'org-publish-attachment
	     :completion-function (lambda (ps)
				    (let* ((favicon-file (concat (plist-get ps :base-directory) "favicon.ico"))
					   (publish-dir (plist-get ps :publishing-directory))
					   (publish-root (file-name-directory (directory-file-name publish-dir)))
					   (root-favicon-file (concat publish-root "favicon.ico")))
				      (copy-file favicon-file root-favicon-file t))))

       (list "js"
	     :base-directory (concat base-dir "js/")
	     :base-extension "js"
	     :publishing-directory static-dir
	     :publishing-function #'org-publish-attachment)

       (list "css"
	     :base-directory (concat base-dir "css/")
	     :base-extension "css"
	     :publishing-directory static-dir
	     :publishing-function #'org-publish-attachment)

       (list "fonts"
	     :base-directory (concat base-dir "fonts/")
	     :base-extension (regexp-opt (list "ttf" "woff"))
	     :publishing-directory static-dir
	     :publishing-function #'org-publish-attachment)

       (list "website" :components '("org" "pages" "rlog" "blog" "images" "js" "css" "fonts"))))


(provide 'publish)
