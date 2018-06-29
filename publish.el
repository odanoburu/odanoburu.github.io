;; several parts of this script are copied from Rasmus' publish.el and
;; Nicolas Petton's setup

;; run with
; bash publish.sh [t]
;; or
; emacs --batch --no-init-file --load publish.el --eval '(org-publish-all t)'
;(package-initialize)

(require 'org)
;(require 'org-ref)
(require 'ox-publish)

;; setting to nil, avoids "Author: x" at the bottom
(setq user-full-name nil)

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
"<link href='http://fonts.googleapis.com/css?family=Libre+Baskerville:400,400italic' rel='stylesheet' type='text/css'>
<link rel='stylesheet' href='/css/site.css' type='text/css'/>
<link rel='icon' type='image/x-icon' href='/favicon.ico'/>")

(defvar bruno-website-html-blog-head
"<link href='http://fonts.googleapis.com/css?family=Libre+Baskerville:400,400italic' rel='stylesheet' type='text/css'>
<link rel='stylesheet' href='/css/site.css' type='text/css'/>")

(defvar bruno-website-html-preamble 
  "<div class='nav'>
<ul>
<li><a href='/'>home</a></li>
<li><a href='/research-log/index.html'>research log</a></li>
<li><a href='/blog/index.html'>personal blog</a></li>
<li><a href='https://github.com/odanoburu'>github</a></li>
<li><a href='/page/publications.html'>publications</a></li>
<li><a href='/page/about.html'>about</a></li>
</ul>
</div>")

(defvar bruno-website-html-postamble 
  "<hr>
<div class='footer'>
Last updated %C. <br>
Built with %c.
</div>")

(setq dir (file-name-directory (or load-file-name buffer-file-name)))

(setq org-publish-project-alist
      `(("org"
         :base-directory ,dir
         :base-extension "org"
         :publishing-directory ,dir
         :publishing-function org-html-publish-to-html
         :section-numbers nil
         :with-toc nil
         :recursive nil
         :html-head ,bruno-website-html-head
         :html-postamble ,bruno-website-html-postamble)

        ("pages"
         :base-directory ,(concat dir "page/")
         :base-extension "org"
         :publishing-directory ,(concat dir "page/")
         :publishing-function org-html-publish-to-html
         :section-numbers nil
         :with-toc nil
         :recursive t
         :html-head ,bruno-website-html-head
         :html-preamble ,bruno-website-html-preamble
         :html-postamble ,bruno-website-html-postamble)

        ("rlog"
         :base-directory ,(concat dir "research-log/")
         :base-extension "org"
         :publishing-directory ,(concat dir "research-log/")
         :publishing-function org-html-publish-to-html
         :section-numbers t
         :with-toc t
         :auto-sitemap t
         :sitemap-style list
         :sitemap-title "sitemap for bruno's research log"
         :recursive t
         :sitemap-filename "index.org"
         :sitemap-file-entry-format "%d *%t*"
         :sitemap-sort-files anti-chronologically
         :html-head ,bruno-website-html-blog-head
         :html-preamble ,bruno-website-html-preamble
         :html-postamble ,bruno-website-html-postamble)

        ("blog"
         :base-directory ,(concat dir "blog/")
         :base-extension "org"
         :publishing-directory ,(concat dir "blog/")
         :publishing-function org-html-publish-to-html
         :section-numbers nil
         :with-toc nil
         :auto-sitemap t
         :sitemap-title "sitemap for bruno's personal blog"
         :recursive t
         :sitemap-filename "index.org"
         :sitemap-file-entry-format "%d *%t*"
         :sitemap-style list
         :sitemap-sort-files anti-chronologically
         :html-head ,bruno-website-html-blog-head
         :html-preamble ,bruno-website-html-preamble
         :html-postamble ,bruno-website-html-postamble)

        ("images"
         :base-directory ,(concat dir "images/")
         :base-extension "jpg\\|gif\\|png\\|ico"
         :publishing-directory ,(concat dir "images/")
         :publishing-function org-publish-attachment)

        ("js"
         :base-directory ,(concat dir "js/")
         :base-extension "js"
         :publishing-directory ,(concat dir "js/")
         :publishing-function org-publish-attachment)

        ("css"
         :base-directory ,(concat dir "css/")
         :base-extension "css"
         :publishing-directory ,(concat dir "css/")
         :publishing-function org-publish-attachment)

        ("website" :components ("org" "pages" "rlog" "blog" "images" "js" "css"))))

(provide 'publish)
