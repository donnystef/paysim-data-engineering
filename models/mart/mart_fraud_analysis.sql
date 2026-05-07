-- Mart: analisis fraud — untuk fraud monitoring dashboard

with base as (
    select * from {{ ref('int_transactions_enriched') }}
),

fraud_only as (
    select * from base where is_fraud = true
)

select
    day_number,
    transaction_type,
    count(*)                                        as fraud_count,
    round(sum(amount), 2)                           as total_fraud_amount,
    round(avg(amount), 2)                           as avg_fraud_amount,
    round(max(amount), 2)                           as max_fraud_amount,
    countif(is_flagged_fraud)                       as system_flagged_count,
    -- Berapa fraud yang TIDAK terdeteksi sistem (missed detection)
    countif(not is_flagged_fraud)                   as missed_by_system_count,
    round(
        countif(is_flagged_fraud) / count(*) * 100
    , 2)                                            as detection_rate_pct

from fraud_only
group by day_number, transaction_type
order by day_number, transaction_type