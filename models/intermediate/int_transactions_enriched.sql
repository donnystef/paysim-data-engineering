-- Intermediate: tambahkan kalkulasi bisnis
-- Di sini kita tambahkan flag-flag yang relevan untuk banking

with base as (
    select * from {{ ref('stg_transactions') }}
),

enriched as (
    select
        *,

        -- Hari ke berapa transaksi ini (simulasi EOD)
        cast(ceil(step / 24.0) as int64)            as day_number,

        -- Jam berapa dalam hari (untuk analisis pola)
        mod(step, 24)                               as hour_of_day,

        -- Flag rekonsiliasi: apakah balance origin masuk akal?
        round(balance_before_origin - amount, 2)
            = balance_after_origin                  as is_balance_reconciled,

        -- Selisih balance (untuk investigasi)
        round(
            balance_before_origin - amount
            - balance_after_origin
        , 2)                                        as balance_discrepancy,

        -- Flag transaksi besar (> 200,000 — threshold AML sederhana)
        amount > 200000                             as is_large_transaction,

        -- Flag rekening pengirim dimulai dengan 'C' (customer)
        -- vs 'M' (merchant) — penting untuk analisis fraud
        starts_with(account_origin, 'C')            as origin_is_customer,
        starts_with(account_destination, 'M')       as dest_is_merchant

    from base
)

select * from enriched