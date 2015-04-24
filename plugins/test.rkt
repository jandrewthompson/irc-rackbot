;; Plugins are loaded not required, so no special (require) 
;; statements are needed here, unless you need custom libs
;;
;; An example plugin:
;; (defplugin plugin-name
;;        (λ (conn msg)
;;          ;;plugin body here
;;          ))

(require json)
(require racket/draw)

(defplugin plugin-test 
           (λ (conn chan msg) 
              (irc-send-message conn chan "This is a TEST plugin") 
              ))



