#lang racket

(require irc)
(require racket/async-channel)
(require (for-syntax 
           racket/match))
(require "utils.rkt")
(require "plugin.rkt")


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

;; All messages flow through this function
;;  Responsible for dispatching to each registered plugin
(define (handle message)
 (printf "MESSAGE: ~s\n" message)
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

;; Start handling messages
(define worker (thread (λ ()
                          (let loop ()
                           (define message (async-channel-get ch))
                           (handle message)
                           (loop)))))


(define (stop-worker)
  (kill-thread worker)
  )


(define (reset-plugins)
  "Clear out plugin handlers"
  (set-box! bot
            (hash-update (unbox bot) "plugins" 
                         (λ (x) 
                            '() ))))

;; Load some plugins!
(define (load-plugins plugin-names bot)
  (for-each 
    (λ (p) 
       (begin
         (load (format "plugins/~a.rkt" p))
         (load-plugin p bot)
         )
       ) 
       plugin-names)
  )

(load-plugins '("plugin-test" "inventory") bot)

#|  Misc...

(irc-send-message connection "#bitswebteam-control" "turinturambar: hi")

(reset-plugins)

(kill-thread worker)

|#
