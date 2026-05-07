-- Mart: ringkasan harian — ini yang akan tampil di dashboard
-- Mirip laporan EOD yang dikirim ke manajemen bank tiap pagi

with base as (
    select * from {{ ref('int_transactions_enriched') }}
)

select
    day_number,
    transaction_type,
    count(*)                                        as total_transactions,
    round(sum(amount), 2)                           as total_amount,
    round(avg(amount), 2)                           as avg_amount,
    round(max(amount), 2)                           as max_amount,
    countif(is_fraud)                               as fraud_count,
    round(countif(is_fraud) / count(*) * 100, 4)   as fraud_rate_pct,
    countif(is_large_transaction)                   as large_transaction_count,
    countif(not is_balance_reconciled)              as recon_mismatch_count

from base
group by day_number, transaction_type
order by day_number, transaction_type