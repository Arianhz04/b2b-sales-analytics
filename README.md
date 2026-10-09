# B2B Sales Analytics

A portfolio project using **MySQL and SQL** to analyze a synthetic B2B CRM sales pipeline. The project demonstrates data staging, data-quality checks, joins, aggregation, CTEs, business metric definitions, and evidence-based sales analysis.

## Business questions

1. **Sales team performance** — compare managers and regional offices using won deals, won revenue, lost deals, win rate, average won deal size, and net difference from suggested retail prices.
2. **Sales agent performance** — compare opportunity volume, won/lost/open pipeline, revenue, win rate, average won deal size, and a simple performance category.
3. **Quarterly trends** — summarize won deals and won revenue by quarter.
4. **Product win rates** — compare win rates across products using decided opportunities only.

## Repository structure

```text
b2b-sales-analytics/
├── data/
│   └── raw/                         # Original CSV files; preserve as source data
├── sql/
│   └── 01_b2b_sales_analytics.sql   # SQL setup, validation, and analysis
├── docs/
│   ├── business_analysis_report.md
│   ├── data_quality_and_assumptions.md
│   └── roadmap.md
├── outputs/                         # Reserved for exported results
├── .gitignore
└── README.md
```

## Dataset

The source is Maven Analytics' **CRM Sales Opportunities** dataset, a synthetic CRM dataset designed for sales analysis. The five CSVs in `data/raw/` are:

- `accounts.csv`
- `products.csv`
- `sales_teams.csv`
- `sales_pipeline.csv`
- `data_dictionary.csv`

Source: [Maven Analytics Data Playground — CRM Sales Opportunities](https://mavenanalytics.io/data-playground/crm-sales-opportunities). A public mirror of the CSV files is available at [Carlscamt/CRM-Sales-Opportunities](https://github.com/Carlscamt/CRM-Sales-Opportunities).

## How to run

1. Install MySQL Server and MySQL Workbench.
2. Clone or download this repository.
3. Open `sql/01_b2b_sales_analytics.sql` in MySQL Workbench.
4. Run the database setup and create the staging tables.
5. Import the CSV files into the matching `stg_*` tables, using the import settings and column order described in the SQL comments.
6. Run the data-quality checks before interpreting the analysis.
7. Run the four business-question sections and compare the results with `docs/business_analysis_report.md`.

The staging tables intentionally store imported values as text in several places so that type conversion and data-quality handling are explicit in SQL. Do not update raw staging values to silently fix source inconsistencies.

## Metric definitions

- **Won deals:** count of opportunities where `deal_stage = 'Won'`.
- **Lost deals:** count of opportunities where `deal_stage = 'Lost'`.
- **Open opportunities:** Prospecting and Engaging opportunities; these are not included in decided-deal win-rate denominators.
- **Win rate:** `Won / (Won + Lost) * 100`. Open opportunities are excluded.
- **Won revenue:** sum of `close_value` for won opportunities.
- **Average won deal size:** won revenue divided by won deals.
- **Net price difference:** for won opportunities with a matched product, sum of `close_value - suggested retail price`. This is not profit, margin, or a confirmed discount.
- **Agent category:** Poor below 60%; Average from 60% through 65% inclusive; Good above 65%.

## Data handling decisions

- Keep `data/raw/` unchanged as source data.
- The pipeline uses `GTXPro` while the products table uses `GTX Pro`. Normalize that spelling in analysis joins with a `CASE` expression; do not rewrite the source CSV or staging value.
- Some opportunities have no account value. Keep these records unless a specific analysis requires a matched account.
- The product table's `sales_price` is described as a **suggested retail price**. A difference from close value should not be described as profit or a discount without additional evidence.
- The source data covers 2017; quarterly analysis uses the close date and reports quarters within that year.

## Current scope and future work

Current scope is MySQL-based analysis and documented business findings. Power BI and in-database SQL Server Python/ML runtime setup are intentionally out of scope for this phase. The next phase is to validate the findings, improve reproducibility, and define a defensible ML use case.

See [the business report](docs/business_analysis_report.md), [data-quality notes](docs/data_quality_and_assumptions.md), and [roadmap](docs/roadmap.md).
