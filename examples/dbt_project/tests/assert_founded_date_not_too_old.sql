-- tests/assert_founded_date_not_too_old.sql
-- Singular Test: 設立日が1800年以降であることを検証する
-- （会社法制定以前のデータは異常値とみなす）

select
    company_id,
    founded_date
from {{ ref('stg_companies') }}
where
    founded_date is not null
    and founded_date < '1800-01-01'
