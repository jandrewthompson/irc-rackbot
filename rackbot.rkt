#lang racket

(require irc)
(require racket/async-channel)
(require (for-syntax 
           racket/match))
(require "utils.rkt")
(require "plugin.rkt")


(struct bot (name nick real-name channel [plugins #:mutable])  #:transparent)
;; Hash holding current bot state
(define rbot 
  (bot "rackbot"
       "rackbot"
       "Rack Bot Jr."
       "#rack-bot-playground"
       '()
       )
  )

(define-values (connection ready)
  (irc-connect "chat.freenode.net" 6667 
               (bot-nick rbot)  
               (bot-name rbot)
               (bot-real-name rbot)  
               )
  )

(irc-join-channel connection (bot-channel rbot))

(define ch (irc-connection-incoming connection))

;; All messages flow through this function
;;  Responsible for dispatching to each registered plugin
(define (handle message)
 (printf "MESSAGE: ~s\n" message)
 (match message
   [(irc-message prefix "PRIVMSG" params _)
    (let ([plugins (bot-plugins rbot)]
          [chan (first params)])
      #|(for-each (λ (plugin)
                   (unless (void? plugin)
                     (plugin connection chan params)))
                plugins
                ) |#
      (for ([p plugins]
            #:final (not (hash-ref p 'final)))
        ((hash-ref p 'body) connection chan params)
        )
      )
    ]
   [_ (void)])
  )

;; Start handling messages
(define worker (thread (λ ()
                          (let loop ()
                           (define message (async-channel-get ch))
                           (handle message)
                           (loop)))))


(define (stop-worker)
  (kill-thread worker)
  )


(define (reset-plugins the-bot)
  "Clear out plugin handlers"
  (set-bot-plugins! the-bot '() ))

;; Load some plugins!
(define (load-plugins plugin-names the-bot)
  (for-each 
    (λ (p) 
       (begin
         (load (format "plugins/~a.rkt" p))
         (load-plugin p the-bot)
         )
       ) 
       plugin-names)
  )

(load-plugins '("plugin-test" "inventory") rbot)

#|  Misc...

(irc-send-message connection "#bitswebteam-control" "turinturambar: hi")

(reset-plugins)

(kill-thread worker)

|#
