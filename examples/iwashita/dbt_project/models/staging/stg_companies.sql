-- models/staging/stg_companies.sql
-- 企業マスタのステージングモデル
-- Layer 1（設計による品質担保）: founded_dateの正規化・型変換を行う

with source as (
    select * from {{ ref('raw_companies') }}
),

cleaned as (
    select
        company_id,
        company_name,
        -- founded_dateの正規化:
        --   YYYY-MM-DD → そのまま
        --   YYYY/MM/DD → ハイフン区切りに変換
        --   YYYYMMDD   → ハイフンを挿入
        case
            when founded_date is null then null
            when length(founded_date) = 8
                 and founded_date not like '%-%'
                 and founded_date not like '%/%'
                then substr(founded_date, 1, 4) || '-'
                     || substr(founded_date, 5, 2) || '-'
                     || substr(founded_date, 7, 2)
            else replace(founded_date, '/', '-')
        end as founded_date_cleaned,
        prefecture,
        industry
    from source
),

typed as (
    select
        cast(company_id as integer)            as company_id,
        cast(company_name as varchar)          as company_name,
        try_cast(founded_date_cleaned as date) as founded_date,
        cast(prefecture as varchar)            as prefecture,
        cast(industry as varchar)              as industry
    from cleaned
)

select * from typed
