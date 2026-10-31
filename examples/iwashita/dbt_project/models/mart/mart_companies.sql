-- models/mart/mart_companies.sql
-- 企業マスタのmartモデル
-- Layer 2（ビルド時の強制）: contractによるスキーマ保証

{{ config(materialized='table') }}

select
    company_id,
    company_name,
    founded_date,
    prefecture,
    industry
from {{ ref('stg_companies') }}
