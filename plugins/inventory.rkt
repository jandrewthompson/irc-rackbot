(require irc)
(require "../plugin.rkt")
(require "../utils.rkt")

(define bag '("fruit" "a cat" "glitter"))

(defplugin inventory
           (λ (conn chan msg)
             (irc-send-message conn chan (format "gives you ~a" (rand-nth bag))) 
              )
           )
