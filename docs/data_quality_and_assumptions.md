# Data Quality and Assumptions

## Source tables and row counts

| CSV / staging table | Rows |
|---|---:|
| accounts / stg_accounts | 85 |
| products / stg_products | 7 |
| sales_teams / stg_sales_teams | 35 |
| sales_pipeline / stg_sales_pipeline | 8,800 |
| data_dictionary / stg_data_dictionary | 21 |
| **Total source rows** | **8,948** |

## Known data-quality observations

### Product name mismatch

The pipeline contains the label `GTXPro`, while the product table contains `GTX Pro`. A direct string join leaves 1,480 pipeline rows unmatched on product name. The analytical join should normalize this one known variant using a `CASE` expression, for example mapping `GTXPro` to `GTX Pro`. Preserve the raw CSV and staging values.

### Missing account values

Approximately 1,425 pipeline opportunities have no account value (about 16.19% of 8,800 rows). Do not silently delete these records. They can still contribute to stage and revenue metrics when the metric does not require an account join.

### Stage and close-value patterns

The reviewed data follows the expected pattern:
- Won opportunities have positive close values and a close date.
- Lost opportunities have a zero close value and a close date.
- Prospecting and Engaging opportunities generally have no close value or close date.

Re-run the quality checks in SQL before each refresh rather than relying on this note alone.

### Agent coverage

There are 35 sales-team records, but five sales agents have no opportunities in the pipeline. Agent rankings based on opportunity activity naturally include only agents with opportunities. Records with blank or missing agent assignment can also cause pipeline-wide totals to differ from agent-level totals.

## Metric assumptions

- Win rate = Won / (Won + Lost) * 100; exclude Prospecting and Engaging.
- Won revenue = sum of close_value for Won opportunities.
- Average won deal size = won revenue / won deals.
- Net price difference = sum of close_value minus suggested retail price for matched products among Won opportunities.
- A positive or negative net price difference does not identify profit, margin, or discount without cost and transaction-pricing context.
- Product labels are normalized only for analytical joins and reporting, not in the source data.

## Import and type handling

The imported staging columns are primarily text. Convert values explicitly with `TRIM`, `CAST`, and `STR_TO_DATE` where required. Validate date formats before aggregating by time period. The quarterly query uses `STR_TO_DATE(close_date, '%Y-%m-%d')`, which matched the source date representation used during analysis.
