;; Freelance Arbitration Smart Contract
;; Manage work disputes, facilitate peer arbitration, and maintain arbitrator reputation scores

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))

;; Data Variables
(define-data-var dispute-counter uint u0)

;; Data Maps
(define-map disputes uint {
    client: principal,
    freelancer: principal,
    amount: uint,
    description: (string-ascii 256),
    status: uint,
    arbitrator: (optional principal),
    resolution: (optional uint)
})

(define-map arbitrators principal {
    reputation-score: uint,
    cases-handled: uint,
    success-rate: uint
})

;; Public Functions
(define-public (create-dispute (freelancer principal) (amount uint) (description (string-ascii 256)))
    (let ((dispute-id (+ (var-get dispute-counter) u1)))
        (map-set disputes dispute-id {
            client: tx-sender,
            freelancer: freelancer,
            amount: amount,
            description: description,
            status: u1,
            arbitrator: none,
            resolution: none
        })
        (var-set dispute-counter dispute-id)
        (ok dispute-id)
    )
)

(define-public (accept-arbitration (dispute-id uint))
    (let ((dispute-data (unwrap! (map-get? disputes dispute-id) err-not-found)))
        (map-set disputes dispute-id 
            (merge dispute-data {
                arbitrator: (some tx-sender),
                status: u2
            })
        )
        (ok true)
    )
)

(define-public (resolve-dispute (dispute-id uint) (resolution uint))
    (let ((dispute-data (unwrap! (map-get? disputes dispute-id) err-not-found)))
        (map-set disputes dispute-id 
            (merge dispute-data {
                resolution: (some resolution),
                status: u3
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-dispute (dispute-id uint))
    (map-get? disputes dispute-id)
)

(define-read-only (get-arbitrator-stats (arbitrator principal))
    (map-get? arbitrators arbitrator)
)

