-- Staging: bersihkan dan standarisasi data mentah
-- Ini lapisan pertama, hanya cleaning — tidak ada logika bisnis di sini

with source as (
    select * from {{ source('paysim_raw', 'transactions_raw') }}
),

cleaned as (
    select
        step,
        -- Konversi step ke simulasi timestamp (step 1 = jam 1 hari pertama)
        timestamp_add(
            timestamp('2024-01-01 00:00:00'),
            interval step hour
        )                                           as transaction_time,
        upper(trim(type))                           as transaction_type,
        round(amount, 2)                            as amount,
        trim(nameOrig)                              as account_origin,
        round(oldbalanceOrg, 2)                     as balance_before_origin,
        round(newbalanceOrig, 2)                    as balance_after_origin,
        trim(nameDest)                              as account_destination,
        round(oldbalanceDest, 2)                    as balance_before_dest,
        round(newbalanceDest, 2)                    as balance_after_dest,
        cast(isFraud as boolean)                    as is_fraud,
        cast(isFlaggedFraud as boolean)             as is_flagged_fraud

    from source
    where amount > 0  -- buang transaksi amount nol, tidak valid
)

select * from cleaned