(require irc)
(require "../plugin.rkt")
(require "../utils.rkt")
(require "../db.rkt")


(define-mongo-struct item "inventory"
                    ([name #:required]) 
                     )

(define (create-item i)
  ;; Stuff new item in db
  (make-item #:name i)
  )

(define (all-items)
  (for/list ([i (mongo-dict-query "inventory" empty)])
    (mongo-dict-ref i 'name)
    )
  )

(defplugin inventory
           (λ (conn chan to msg)
             (irc-send-message conn chan (format "gives you ~a" 
                                                 (rand-nth (all-items)))) 
              )
           )
