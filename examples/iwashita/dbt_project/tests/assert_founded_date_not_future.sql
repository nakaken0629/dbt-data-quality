-- tests/assert_founded_date_not_future.sql
-- Singular Test: 設立日が未来日でないことを検証する
-- このSQLが0行を返せばテスト通過

select
    company_id,
    founded_date
from {{ ref('stg_companies') }}
where
    founded_date is not null
    and founded_date > current_date
