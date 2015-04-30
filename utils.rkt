#lang racket

(provide rand-nth)
(provide box-hash-ref)

;; UTILS
(define (rand-nth lst)
  (list-ref lst (random (length lst))))

(define (box-hash-ref b v)
  "Where b is a boxed hash table, and v is key to ref"
  (hash-ref (unbox b) v)
  )

(define (parse-nick-msg params)
  (let* ([parts (string-split params  #:trim? #t)]
         [nick (string-trim (first parts))]
         [msg (string-trim (string-join (rest parts)))]
         )
    (if (regexp-match? #rx".:"  nick)
          `(,nick ,msg)
          `("" ,params)
          )
   )
  )
