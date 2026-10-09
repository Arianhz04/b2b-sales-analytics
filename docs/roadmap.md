# Project Roadmap

## Current phase — SQL analysis

- [x] Select a B2B CRM sales dataset.
- [x] Import the five source CSVs into MySQL staging tables.
- [x] Check row counts, unique opportunity IDs, missing values, stage/value patterns, and unmatched references.
- [x] Analyze manager and regional performance.
- [x] Analyze agent performance with the agreed win-rate categories.
- [x] Summarize won deals and revenue by quarter.
- [x] Compare product win rates using decided opportunities.
- [x] Document metric definitions, assumptions, and known data-quality issues.

## Next phase — Reproducibility and portfolio polish

- [ ] Re-run every query from a clean MySQL database using the repository instructions.
- [ ] Validate report figures against fresh query outputs and update the report if any results differ.
- [ ] Capture small, clearly labeled result exports in `outputs/` (avoid committing unnecessary duplicate raw data).
- [ ] Add a concise data dictionary / schema diagram if it improves clarity.
- [ ] Review SQL formatting, query ordering, and import instructions end to end.

## Future phase — Machine-learning problem definition

Do not start with an arbitrary model. First define a business question that the available data can support. Potential candidate: predict whether an opportunity will be won, using only features available at the time of prediction.

Before modeling:
- Define the prediction point and target precisely.
- Exclude leakage features such as close date and close value if predicting before a deal closes.
- Decide how to handle open opportunities and missing account values.
- Split data in a way that reflects the intended use case; consider time-based validation if timestamps support it.
- Establish a simple baseline and suitable metrics before trying complex models.
- Keep model development separate from the current descriptive SQL analysis.

## Out of scope for now

Power BI and SQL Server in-database Python/ML runtime troubleshooting are intentionally excluded from this phase. Current work is focused on MySQL/T-SQL learning and reliable business analysis.
