# dbt-data-quality

技術書典で頒布した同人誌『dbtとそれにまつわる技術を語ろうじゃないか』の章「dbtで実践するデータ品質設計」（著：岩下煕一）のサンプルコードを置いているリポジトリです。

## 本書について

本書では、著者それぞれがdbtにまつわる興味深いトピックを選び、アラカルト形式で紹介しています。dbtの基本的な使い方を順に解説する入門書ではありません。実際に業務でdbtを使ってきた著者が「これは面白い」「これは知っておいてほしい」と感じたテーマに絞って掘り下げています。

## 章の概要：dbtで実践するデータ品質設計

「dbt testを書いていれば品質は大丈夫」とは限りません。テストで捕捉できるのは、すでに定義された異常だけです。カラム名の揺れ、型の不整合、意図しないNULLの混入といった問題は、テストより手前の設計段階で防げます。

この章では、Shift-Left Data Quality（上流で防げるものは上流で防ぐ）の考え方にもとづき、データ品質を次の4つの層で捉えるモデルを提案しています。

| レイヤー | 名称 | 役割 | dbtの機能・ツール |
| --- | --- | --- | --- |
| Layer 1 | 設計による制約 | 異常値が入り込む余地をなくす構造を設計段階で作る | 型選択・NULLセマンティクス・命名規則、schema.yml description |
| Layer 2 | ビルド時の強制 | スキーマの合意をビルド時に強制する | dbt contracts（1.5+）、constraints |
| Layer 3 | テストによる検証 | データの値が期待通りかをテスト実行時に検証する | dbt test（generic / singular / unit）、dbt-utils |
| Layer 4 | 監視・観測 | 継続的・時系列での品質状態を観測する | dbt source freshness、elementary |

章の後半では、Claude CodeなどのCoding Agentを使ってこの4層モデルを効率よく実装・維持する方法も紹介しています。

## サンプルプロジェクト

`examples/dbt_project/` は、DuckDBで動くdbtプロジェクトです。クラウド環境がなくても手元で動かせます。

seedデータ `raw_companies.csv` は30行の企業マスタです。設立日（`founded_date`）の日付フォーマットに、意図的に揺れを入れています。

| company_id | founded_date | 形式 |
| --- | --- | --- |
| 1 | 2015-04-01 | YYYY-MM-DD |
| 6 | 2019/06/01 | スラッシュ区切り |
| 27 | 20200401 | 区切りなし |

### ディレクトリ構成

```
examples/dbt_project/
├── dbt_project.yml
├── profiles.yml                  # DuckDB（dev.duckdb）への接続設定
├── packages.yml                  # dbt_utils / elementary
├── seeds/
│   └── raw_companies.csv         # 日付フォーマットに揺れのある企業マスタ
├── models/
│   ├── staging/
│   │   ├── stg_companies.sql     # Layer 1: 型・NULL・命名の正規化
│   │   └── _staging.yml          # Layer 3: generic / unit tests、Layer 4: elementary監視設定
│   └── mart/
│       ├── mart_companies.sql
│       └── _mart.yml             # Layer 2: contract.enforced
└── tests/
    ├── assert_founded_date_not_future.sql    # Layer 3: singular test
    └── assert_founded_date_not_too_old.sql   # Layer 3: singular test
```

### 実行方法

```bash
pip install dbt-core dbt-duckdb
cd examples/dbt_project
dbt deps --profiles-dir .
dbt build --profiles-dir .
```

`dbt build` を実行すると、seed・model・testが依存関係の順に実行されます。elementaryを除いた内訳は次のとおりです。

- Seed：`raw_companies` のロード（1）
- Model：`stg_companies`、`mart_companies` の構築（2）
- Unit Test：日付正規化ロジックの検証（1）
- Generic Tests：unique、not_null、accepted_valuesなど（9）
- Singular Tests：設立日の妥当性検証（2）

elementaryを有効にすると、上記に加えて `volume_anomalies` と `column_anomalies` の2テストも実行されます。なお、Layer 4の監視はデータがある程度蓄積しないと効果を確認しにくいため、このサンプルには設定例だけを入れています。

## 謝辞

dbtを開発・提供しているdbt Labs, Inc.に感謝申し上げます。本書の執筆と出版にあたっては、株式会社RONNABYTEに参加の機会をいただきました。企業ブースでの販売を許可いただいたちゅらデータ株式会社にも感謝いたします。
