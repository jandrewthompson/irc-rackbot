#lang racket

(require (for-syntax 
           racket/match))
(require (for-syntax 
           racket/syntax))
(require "utils.rkt")

(provide defplugin)
(provide load-plugin)


(define (load-plugin plugin-name bot)
  (let ([p (string->symbol 
             (string-append plugin-name "-init"))])
    (eval `(,p bot)))
  )


;; Thare be magic here.
;;  Provies the all-important (defplugin) macro for building plugins.
;;  the plugin body should be a lambda that accepts three params: conn, chan-name and args      
(define-syntax (defplugin stx)
  (match (syntax->list stx)
    [(list _ name body) ; pattern match plugin def
     (let ([fname (format-id stx "~a-init" name)]) ; format the init func name
       (datum->syntax stx 
                      `(begin 
                         #|                         (provide ,fname) |#
                         (define (,fname  bot)  
                           (set-box! bot  
                                     ;; Register the plugin body with the bot
                                     (hash-update (unbox bot) "plugins" 
                                                  (λ (x) 
                                                     (cons ,body x) )))))                   
                      ))
     ]
    )
  )
