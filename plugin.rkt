#lang racket

(require (for-syntax 
           racket/match))
(require (for-syntax 
           racket/syntax))
(require "utils.rkt")

(provide defplugin)
(provide load-plugin)


(define (load-plugin plugin-name the-bot)
  (begin
    (displayln the-bot)
    (let ([p (string->symbol 
               (string-append plugin-name "-init"))])
      (eval `(,p ,the-bot))))
  )


;; Thare be magic here.
;;  Provies the all-important (defplugin) macro for building plugins.
;;  the plugin body should be a lambda that accepts three params: conn, chan-name and args      
;;
;; TODO: figure out how to refactor the pattern matching here.  First
;;       clause if for #:final plugins (no further processing). Else, allow
;;       the next plugin in the chain to exec as well.
(define-syntax (defplugin stx)
  (match (syntax->list stx)
    [(list _ name body) ; pattern match plugin def
     (let ([fname (format-id stx "~a-init" name)]) ; format the init func name
       (datum->syntax stx 
                      `(begin 
                         (define (,fname  the-bot)  
                           (set-bot-plugins! the-bot 
                                             ;; Register the plugin body with the bot
                                             (cons ,body  
                                                   (bot-plugins the-bot)))))                   
                      ))
     ]
    )
  )

(define halt #t)
