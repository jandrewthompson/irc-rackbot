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

;; All messages flow through this function
;;  Responsible for dispatching to each registered plugin
(define (handle message)
 (printf "MESSAGE: ~s\n" message)
 (match message
   [(irc-message prefix "PRIVMSG" params _)
    (let* ([plugins (bot-plugins rbot)]
          [chan (first params)]
          [nick-msg (parse-nick-msg (second params))]
          [nick (first nick-msg)]
          [msg (second nick-msg)]
          )
      (for/and ([p (reverse plugins)])
        ;; if plugin returns 'continue, keep processing plugins
        ;;   otherwise halt by default
        (if (eq? 'continue (p connection chan nick msg params)) 
          #t
          #f
          )
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
         (displayln the-bot)
         (load-plugin p the-bot)
         )
       ) 
       plugin-names)
  )

(load-plugins '("plugin-test" "inventory") rbot)

#|  Misc...

(irc-send-message connection "#bitswebteam-control" "turinturambar: hi")

(reset-plugins rbot)

(stop-worker)

(kill-thread worker)

(define msg (irc-message "turinturambar!~turintura@50.106.225.3" "PRIVMSG" '("#rack-bot-playground" "rackbot: this is for you") ":turinturambar!~turintura@50.106.225.3 PRIVMSG #rack-bot-playground :rackbot: this is for you\r" ))

|#





