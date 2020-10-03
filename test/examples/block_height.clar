(define-data-var height uint 0)

(define-read-only (read)
  (ok (var-get height)))

(define-public (update)
  (begin
    (var-set height block-height)
    (ok (var-get height))))
