#lang racket

(require db/mongodb)

(define m (create-mongo))

(define db (make-mongo-db m "rackbot"))

(current-mongo-db db)


;(close-mongo! m)
