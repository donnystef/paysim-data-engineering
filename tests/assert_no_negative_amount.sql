-- Test ini akan GAGAL kalau ada amount negatif
-- dbt akan alert kita kalau data quality bermasalah

select *
from {{ ref('stg_transactions') }}
where amount < 0