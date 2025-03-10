;; -*- lexical-binding: t -*-

;; several parts of this script are copied from Rasmus' publish.el
;; and Nicolas Petton's setup

;; run with
;;; bash make-site.sh [t]
;; or
;;; emacs --batch --no-init-file --load publish.el --eval '(org-publish-all t)'

;; (package-initialize)

(require 'htmlize)
(require 'ox-html)
(require 'xml)

;; could use shr-dom-to-xml
(defmacro with-xml (&rest xml)
  ;; NOTE: this is XML export, not HTML, so we have to be careful
  ;; with HTML5-breaking stuff, like self-closing non-void elements
  ;; (in XML it's okay to write <script defer=""/>, but in HTML5
  ;; it's not, we have to close the element with </script>
  `(with-temp-buffer
     (xml-print (list ,@xml))
     (buffer-string)))

(defvar bruno-website-rss-feed-link
  (with-xml
   '(a ((href . "/feed.xml")
	(download . "feed.xml")
	(target . "_blank")
	(class . "no-decoration"))
       (object ((id . "rss-icon")
		(type . "image/svg+xml")
		(data . "/static/rss.svg"))
	       "RSS icon"))))

(defun bruno-website-with-begin-export-html (str)
  (format "\n#+BEGIN_EXPORT html\n%s\n#+END_EXPORT" str))

(push (cons "rss-icon-link" (format "@@html:%s@@" bruno-website-rss-feed-link))
      org-export-global-macros)
(push (cons "section-separator" (bruno-website-with-begin-export-html (with-xml '(span ((class . "section-separator")) ""))))
      org-export-global-macros)

;; Customize the HTML output
(setq org-html-validation-link nil ;; Don't show validation link
      org-html-head-include-scripts nil       ;; Use our own scripts
      org-html-head-include-default-style nil ;; Use our own styles
      org-html-head (with-xml '(link ((rel . "stylesheet") (href . "/static/site.css")))))

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


(defvar bruno-website-blog-title "Bruno Cuconato's Blog")

(defvar bruno-website-html-head
  (with-xml
   '(link ((rel . "stylesheet") (href . "/static/site.css")))
   '(link ((rel . "icon") (type . "image/x-icon") (href . "/static/favicon.ico")))
   '(script ((src . "/static/site.js") (defer . ""))
	    ;; NOTE: this empty string matters! (see note on
	    ;; with-xml definition)
	    ""
	    )))

(defvar bruno-website-html-blog-head bruno-website-html-head)

(defvar bruno-website-html-preamble
  (with-xml
   '(div ((class . "nav"))
	 (ul ((id . "navlinks") (class . "horizontal-list"))
	     (li () (a ((href . "/")) "Home"))
	     (li () (a ((href . "/blog/index.html")) "Blog"))
	     ;; (li () (a ((href . "/research.html")) "Research"))
	     (li () (a ((href . "/about.html")) "About"))))))

(defvar bruno-website-html-postamble "")

(defvar bruno-website-base-dir (file-name-directory (or load-file-name buffer-file-name)))
(defvar bruno-website-publish-dir (file-name-as-directory (concat bruno-website-base-dir "public")))
(defvar bruno-website-static-dir (file-name-as-directory (concat bruno-website-publish-dir "static")))

(defvar bruno-website-with-creator nil)

(defun bruno-website-org-publish-find-description (file project)
  (org-publish-find-property file :description project 'html))

(defun bruno-website-format-blog-entry (entry style project)
  (let ((entry-lang (org-publish-find-property entry :language project))
	(entry-keywords (or (org-publish-find-property entry :keywords project 'html) "")))
    (if (member "draft" (split-string entry-keywords " " t))
	"" 				; hide it
      (with-xml
       `(div ((class . "post")
	      (data-date . ,(format-time-string "%Y-%m-%d" (org-publish-find-date entry project)))
	      (lang . ,(or entry-lang ""))
	      (data-keyword . ,(if entry-lang
				   (concat entry-keywords " lang-" entry-lang)
				 entry-keywords)))
	     (dt ()
		 (a ((href . ,(concat (file-name-sans-extension entry) ".html")))
		    ,(org-publish-find-title entry project)))
	     (dd ()
		 ,(or (bruno-website-org-publish-find-description entry project) "")))))))

(defun bruno-website-sitemap (title files)
  (let ((file-contents (cl-mapcar #'car (cdr files))))
    (concat "#+TITLE: " title "\n\n"
	    "#+BEGIN_EXPORT html\n"
	    "<h3>Tags</h3>"
	    "<!-- javascript-powered feature: --> <ul id=\"keywords-menu\" class=\"horizontal-list\"></ul>"
	    "<h3>Posts " bruno-website-rss-feed-link "</h3>"
	    "<dl class=\"org-dl\">"
	    (apply #'concat file-contents)
	    "</dl>"
	    "\n#+END_EXPORT")))

(defvar bruno-website-url "https://odanoburu.github.io/")

(defun bruno-website-publish-url (file-name publish-dir)
  (url-encode-url (concat bruno-website-url (file-relative-name publish-dir bruno-website-publish-dir) file-name)))

(defvar bruno-website-rfc822-time-format-string
  ;; Tue, 30 Nov 2021 00:00:00 +0000
  "%a, %d %b %Y %H:%M:%S GMT")

(defun bruno-website-rss-entry (project source publish-dir)
  (let ((title (org-publish-find-title source project))
	(date (org-publish-find-date source project))
	(lang (org-publish-find-property source :language project))
	(description (bruno-website-org-publish-find-description source project))
	(dest-url (bruno-website-publish-url (concat (file-name-sans-extension (file-name-nondirectory source)) ".html") publish-dir)))
    (when description
      (unless (member
	       "draft"
	       (split-string
		(or (org-publish-find-property source :keywords project 'html) "")
		" "
		t))
	(org-publish-cache-set-file-property
	 source
	 :rss
	 `(,(format-time-string "%Y-%m-%d" date)
           item ()
		(title () ,title)
		(description () ,description)
		,(if lang `(category ((domain . "https://www.rfc-editor.org/info/bcp47")) ,lang) "")
		(pubDate () ,(format-time-string bruno-website-rfc822-time-format-string date))
		(link () ,dest-url)
		(guid ((isPermaLink . "true")) ,dest-url)))))))

(defun bruno-website-rss (entry-rss publish-dir)
  (with-temp-file (concat publish-dir "feed.xml")
    (insert "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
    (xml-print
     `((rss ((version . "2.0")
	     (xmlns:atom . "http://www.w3.org/2005/Atom"))
	    (channel ()
		     (title () ,bruno-website-blog-title)
		     (link () ,bruno-website-url)
		     (atom:link ((href . ,(concat bruno-website-url "feed.xml"))
				 (ref . "self")
				 (type . "application/rss+xml")))
		     (description () ,(concat bruno-website-url "about.html"))
		     (lastBuildDate () ,(format-time-string bruno-website-rfc822-time-format-string))
		     (docs () "https://www.rssboard.org/rss-specification")
		     ,@entry-rss))))))

(push (cons "publication" "(eval (bruno-website-publication-to-html $1))")
      org-export-global-macros)
(defvar bruno-website-publications-url "https://www.inf.puc-rio.br/~bclaro/publications/"
  ;; transfer files there with lftp
  "URL where the publication files are stored.")
(defun bruno-website-publication-to-html (key)
  "KEY must be the file name (without extension) of the .pdf and
the .bib pertaining to the publication in question.

Ideally it should be the the key of the bibtex entry too, and
should follow the schema
 {first author surname}{year}-{meaningful but short title}-{venue}"
  (format "@@html:%s@@"
	  (replace-regexp-in-string "\n" " "
				    (with-xml
				     `(span ((class . "publication-links"))
					    (a ((href . ,(concat bruno-website-publications-url key ".bib"))
						(target . "_blank")
						(type . "text/plain"))
					       ".bib")
					    (a ((href . ,(concat bruno-website-publications-url key ".pdf"))
						(target . "_blank")
						(type . "application/pdf"))
					       ".pdf")))
				    t t)))

(setq org-publish-project-alist
      (list
       (list "org"
	     :base-directory bruno-website-base-dir
	     :base-extension "org"
	     :publishing-directory bruno-website-publish-dir
	     :publishing-function #'org-html-publish-to-html
	     :section-numbers nil
	     :with-toc nil
	     :recursive nil
	     :with-author nil ;; Don't include author name
	     :with-creator bruno-website-with-creator
	     :time-stamp-file nil
	     :html-head bruno-website-html-head
	     :html-preamble bruno-website-html-preamble
	     :html-postamble bruno-website-html-postamble
	     :completion-function (lambda (ps)
				    (let* ((robots-file (concat (plist-get ps :base-directory) "robots.txt"))
					   (publish-dir (plist-get ps :publishing-directory))
					   (root-robots-file (concat publish-dir "robots.txt")))
				      (copy-file robots-file root-robots-file t))))

       (list "blog"
	     :base-directory (concat bruno-website-base-dir "blog/")
	     :base-extension "org$"
	     :publishing-directory (concat bruno-website-publish-dir "blog/")
	     :publishing-function (list #'org-html-publish-to-html #'bruno-website-rss-entry)
	     :section-numbers nil
	     :with-toc nil
	     :with-author nil ;; Don't include author name
	     :with-creator bruno-website-with-creator
	     :auto-sitemap t
	     :sitemap-title bruno-website-blog-title
	     :recursive t
	     :sitemap-filename "index.org"
	     :sitemap-format-entry #'bruno-website-format-blog-entry
	     :sitemap-function #'bruno-website-sitemap
	     :sitemap-sort-files 'anti-chronologically
	     ;; abuse completion function to generate RSS; each file
	     ;; has its corresponding rss entry stored in the cache
	     ;; (so we just generate it once) and this function then
	     ;; collects them and publishes the RSS
;;; TODO: check if the file actually changed (with
;;; hashes) and if not, skip writing to disk
	     :completion-function (lambda (proj)
				    (let ((entries-rss))
				      (map-do (lambda (k v)
						(let ((rss (plist-get v :rss)))
						  (when rss
						    (push rss entries-rss))))
					      org-publish-cache)
                                      (setq entries-rss (seq-sort-by #'car (lambda (a b) (string-lessp b a)) entries-rss))
				      (bruno-website-rss (mapcar #'cdr entries-rss) bruno-website-publish-dir)))
	     :html-head bruno-website-html-blog-head
	     :html-preamble bruno-website-html-preamble
	     :html-postamble bruno-website-html-postamble)

       (list "images"
	     :base-directory (concat bruno-website-base-dir "images/")
	     :base-extension (regexp-opt (list "jpg" "gif" "png" "ico" "svg"))
	     :publishing-directory bruno-website-static-dir
	     :publishing-function #'org-publish-attachment
	     :completion-function (lambda (ps)
				    (let* ((favicon-file (concat (plist-get ps :base-directory) "favicon.ico"))
					   (publish-dir (plist-get ps :publishing-directory))
					   (publish-root (file-name-directory (directory-file-name publish-dir)))
					   (root-favicon-file (concat publish-root "favicon.ico")))
				      (copy-file favicon-file root-favicon-file t))))

       (list "js"
	     :base-directory (concat bruno-website-base-dir "js/")
	     :base-extension "js"
	     :publishing-directory bruno-website-static-dir
	     :publishing-function #'org-publish-attachment)

       (list "css"
	     :base-directory (concat bruno-website-base-dir "css/")
	     :base-extension "css"
	     :publishing-directory bruno-website-static-dir
	     :publishing-function #'org-publish-attachment)

       (list "fonts"
	     :base-directory (concat bruno-website-base-dir "fonts/")
	     :base-extension (regexp-opt (list "ttf" "woff"))
	     :publishing-directory bruno-website-static-dir
	     :publishing-function #'org-publish-attachment)

       (list "website"
	     :components '("org" "blog" "images" "js" "css" "fonts"))))


(provide 'publish)
