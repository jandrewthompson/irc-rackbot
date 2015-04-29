(require irc)
(require "../plugin.rkt")

;; Plugins are loaded not required, so no special (require) 
;; statements are needed here, unless you need custom libs
;;
;; An example plugin:
;; (defplugin plugin-name
;;        (λ (conn msg)
;;          ;;plugin body here
;;          ))

(defplugin plugin-test 
           (λ (conn chan to msg params) 
              (let ([response "This is a test plugin"])
              (if (not (eq? "" to))
               (irc-send-message conn chan (format "~a: ~a" to response) )
               (irc-send-message conn chan response) 
                ) 
               )
              ))



