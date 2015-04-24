#lang racket

(require irc)
(require racket/async-channel)
(require (for-syntax 
           racket/match))

;; UTILS
(define (rand-nth lst)
  (list-ref lst (random (length lst))))

(define (box-hash-ref b v)
  "Where b is a boxed hash table, and v is key to ref"
  (hash-ref (unbox b) v)
  )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Hash holding current bot state
(define bot 
  (box #hash(["nick" . "rackbot"]
             ["name" . "rackbot"]
             ["real-name" . "Rack Bot Jr."]
             ["channel" . "#rack-bot-playground"]
             ["plugins" . ()] 
             )))

(define-values (connection ready)
  (irc-connect "chat.freenode.net" 6667 
               (box-hash-ref bot "nick")  
               (box-hash-ref bot "name")  
               (box-hash-ref bot "real-name")  
               )
  )

(irc-join-channel connection (box-hash-ref bot "channel"))

(define ch (irc-connection-incoming connection))

(define (handle message)
 (printf "COMMAND ~s\n" message)
 (match message
   [(irc-message prefix "PRIVMSG" params _)
    (let ([plugins (box-hash-ref bot "plugins")]
          [chan (first params)])
      (for-each (λ (plugin)
                   (unless (void? plugin)
                     (plugin connection chan params)))
                plugins
                ))
    ]
   [_ (void)])
  )

(define worker (thread (λ ()
                          (let loop ()
                           (define message (async-channel-get ch))
                           (handle message)
                           (loop)))))


(define (stop-worker)
  (kill-thread worker)
  )

(define-syntax (defplugin stx)
  (match (syntax->list stx)
    [(list _ name body) 
     (datum->syntax stx 
                    `(begin 
                       (define ,name ,body)
                       (set-box! bot
                                 (hash-update (unbox bot) "plugins" 
                                              (λ (x) 
                                                 (cons ,name x) ))))                   
                    )
     ]
    )
  )

(define (reset-plugins)
  "Clear out plugin handlers"
  (set-box! bot
            (hash-update (unbox bot) "plugins" 
                         (λ (x) 
                            '() ))))

;; Load some plugins!
(let ()
 (load "plugins/test.rkt")
 )


#|  Misc...

(irc-send-message connection "#bitswebteam-control" "turinturambar: hi")

(reset-plugins)

(kill-thread worker)

|#
