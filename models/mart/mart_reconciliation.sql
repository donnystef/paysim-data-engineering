-- Mart: rekonsiliasi harian — simulasi laporan yang dikirim ke BI/OJK

with base as (
    select * from {{ ref('int_transactions_enriched') }}
)

select
    day_number,
    transaction_type,
    count(*)                                        as total_transactions,
    countif(is_balance_reconciled)                  as reconciled_count,
    countif(not is_balance_reconciled)              as mismatch_count,
    round(
        countif(is_balance_reconciled) / count(*) * 100
    , 2)                                            as reconciliation_rate_pct,
    round(sum(
        case when not is_balance_reconciled
        then abs(balance_discrepancy) else 0 end
    ), 2)                                           as total_discrepancy_amount

from base
group by day_number, transaction_type
order by day_number, transaction_type