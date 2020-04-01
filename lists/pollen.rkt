#lang racket/base

(require pollen/core pollen/decode pollen/setup txexpr racket/string)

(provide (except-out (all-defined-out)
                     undefined-function-for-target-error))

;; helpers

(define (my-decode-paragraphs elements)
  (decode-paragraphs elements
                     #:linebreak-proc
                     (λ (x) (decode-linebreaks x '(span ((class "raw-linebreak")) " ")))
                     #:force? #t))

(define (make-id author title year)
  (string-replace (format "~a-~a-~a" author title year)
                  #px"\\s+" "_"))

(define toc-id "toc")

(define (html-make-toc elements)
  (list 'div
        (list 'h2 (list (list 'id toc-id)) "Table of Contents")
        (txexpr 'ul empty
                (for/list ([element (in-list (filter txexpr? elements))])
                  (let ((title (attr-ref element 'data-title))
                        (author (attr-ref element 'data-author))
                        (year (attr-ref element 'data-year)))
                    (list 'li title " (" author ")"
                          (txexpr 'a `((href ,(format "#~a" (make-id author title year))))
                                  (list "⤵"))))))))

;; pollen

(module setup racket/base
  (provide (all-defined-out))
  (define poly-targets '(html org)))

(define (root . elements)
  (let ((processed-elems (decode-elements elements
                                          #:string-proc (compose1 smart-quotes smart-dashes))))
    (txexpr 'root empty
            (case (current-poly-target)
              ((org) processed-elems)
              ((html)
               (cons
                (html-make-toc elements)
                processed-elems))
              (else
               (undefined-function-for-target-error))))))

(define (undefined-function-for-target-error)
  (error "Undefined tag function for poly target " (current-poly-target)))


(define (media-piece medium statuses other-attrs
                     #:title title #:author author #:year year #:status status
                     #:subtitle subtitle elems)
  (unless (member status statuses)
       (error "Unknown status: " status))
  (case (current-poly-target)
    ((org)
     ;; use https://orgmode.org/manual/Property-syntax.html#Property-syntax ?
     (txexpr medium other-attrs
             `("\n* " ,title ,@(if subtitle (list "—" subtitle) '())
                      ", by " ,author " (" ,year ")" " :" ,status ":"
                      ,@elems)))
    ((html)
     (txexpr 'article (append other-attrs (list `(class ,(symbol->string medium))
                                                `(data-author ,author)
                                                `(data-year ,year)
                                                `(data-title ,title)
                                                `(id ,(make-id author title year))))
             `(,(txexpr* 'div (list `(class "metadata"))
                         `(h2 ,title
                              ,@(if subtitle (list "---" subtitle)
                                    empty)
                              ,(txexpr 'a `((href ,(format "#~a" toc-id)))
                                       (list "⤴")))
                         `(h3 "by " ,`(span ((class "author")) ,author)
                              " (" ,year ") ---" ,`(span ((class "status")) ,status)))
               ,@elems
               (hr))))
    (else
     (undefined-function-for-target-error))))

(define (book #:title title #:author author #:published published #:status status
              #:subtitle [subtitle #f] #:publisher [publisher #f] . elems)
  (media-piece 'book '("read" "tbr" "reading")
               (if publisher (list 'publisher publisher) empty)
               #:title title #:author author #:year published
               #:status status #:subtitle subtitle elems))

(define (film #:title title #:director director #:released released #:status status
              #:subtitle [subtitle #f] . elems)
  (media-piece 'film '("watched" "tbw") empty
               #:title title #:author director #:year released #:status status
               #:subtitle subtitle elems))

(define (synopsis . elems)
  (case (current-poly-target)
    ((org)
     (txexpr 'synopsis empty
             `("** Synopsis" ,@elems)))
    ((html)
     (txexpr 'div '((class "synopsis"))
             (append (list '(h4 "Synopsis"))
                     (decode-elements elems
                                      #:txexpr-elements-proc my-decode-paragraphs))))
    (else
     (undefined-function-for-target-error))))


(define (opinion . elems)
  (case (current-poly-target)
    ((org)
     (txexpr 'opinion empty
             `("** Opinion" ,@elems)))
    ((html)
     (txexpr 'div '((class "opinion"))
             (append (list '(h4 "Opinion"))
                     (decode-elements elems
                                      #:txexpr-elements-proc my-decode-paragraphs))))
    (else
     (undefined-function-for-target-error))))
