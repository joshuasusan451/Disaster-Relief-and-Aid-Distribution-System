;; Aid Shipment Tracking Contract

(define-map shipments
  { shipment-id: uint }
  {
    org-id: uint,
    contents: (string-utf8 200),
    origin: (string-utf8 100),
    destination: (string-utf8 100),
    status: (string-ascii 20),
    timestamp: uint
  }
)

(define-data-var shipment-id-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))

(define-read-only (get-shipment (shipment-id uint))
  (map-get? shipments { shipment-id: shipment-id })
)

(define-public (create-shipment
    (org-id uint)
    (contents (string-utf8 200))
    (origin (string-utf8 100))
    (destination (string-utf8 100)))
  (let
    ((new-shipment-id (+ (var-get shipment-id-nonce) u1)))
    (map-set shipments
      { shipment-id: new-shipment-id }
      {
        org-id: org-id,
        contents: contents,
        origin: origin,
        destination: destination,
        status: "In Transit",
        timestamp: block-height
      }
    )
    (var-set shipment-id-nonce new-shipment-id)
    (ok new-shipment-id)
  )
)

(define-public (update-shipment-status (shipment-id uint) (new-status (string-ascii 20)))
  (let
    ((shipment (unwrap! (get-shipment shipment-id) ERR_NOT_FOUND)))
    (map-set shipments
      { shipment-id: shipment-id }
      (merge shipment {
        status: new-status,
        timestamp: block-height
      })
    )
    (ok true)
  )
)

(define-read-only (get-all-shipments)
  (ok (var-get shipment-id-nonce))
)

