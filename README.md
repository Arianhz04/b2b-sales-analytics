# B2B Sales Analytics

A practical analytics project built around a synthetic B2B CRM sales pipeline. It starts with SQL-based business analysis and extends into a documented machine-learning experiment to assess whether the available CRM fields can predict completed deal outcomes.

## Project overview

The project answers four business questions:

1. How do sales teams perform against one another?
2. Are there meaningful differences in sales-agent performance?
3. How does sales performance change by quarter?
4. Do products have different win rates?

The SQL analysis is the core business-analysis deliverable. The Python extension tests a separate question: **do the available account, product and sales-assignment fields provide useful signal for distinguishing Won from Lost opportunities?**

## Key finding

The first model comparison did **not** establish a useful win/loss predictor. The majority-class baseline achieved 63.14% test accuracy, while the tested models had ROC-AUC scores close to 0.50 or below. The project therefore does not recommend deploying a classifier from these features.

That is an important result, not a claim of model success: it shows why a baseline, held-out evaluation and an explicit decision not to select a model matter. Better pre-outcome CRM activity data and a clearly defined prediction point are the next steps.

## Repository structure

```text
b2b-sales-analytics/
├── data/raw/                  # Source CSVs; keep unchanged
├── data/processed/            # Created by notebooks; not source data
├── sql/
│   └── 01_b2b_sales_analytics.sql
├── notebooks/
│   ├── 01_data_understanding_and_eda.ipynb
│   ├── 02_data_preparation_and_feature_engineering.ipynb
│   └── 03_model_training_and_evaluation.ipynb
├── docs/
│   ├── business_analysis_report.md
│   ├── data_quality_and_assumptions.md
│   ├── ml_methodology.md
│   └── ml_model_card.md
├── outputs/                   # SQL result exports
├── reports/                   # Generated evaluation summaries
├── requirements.txt
└── README.md
```

## Data

The project uses Maven Analytics' [CRM Sales Opportunities dataset](https://mavenanalytics.io/data-playground/crm-sales-opportunities), a synthetic dataset intended for analytics practice. Expected source files in `data/raw/` are:

- `sales_pipeline.csv`
- `accounts.csv`
- `products.csv`
- `sales_teams.csv`
- `data_dictionary.csv`

The raw files are preserved. In particular, the product spelling mismatch `GTXPro` versus `GTX Pro` is handled with a derived join key rather than by modifying source values.

## Run the SQL analysis

1. Install MySQL Server and MySQL Workbench.
2. Open `sql/01_b2b_sales_analytics.sql`.
3. Follow the script comments to create staging tables and import the CSVs.
4. Run the data-quality checks before interpreting the analysis.
5. Run the four business-question sections and compare results with `docs/business_analysis_report.md`.

## Run the Python notebooks

Use Python 3.10 or newer. From the repository root:

```bash
python -m venv .venv
# Windows:
.venv\Scripts\activate
# macOS/Linux:
source .venv/bin/activate

python -m pip install --upgrade pip
pip install -r requirements.txt
jupyter lab
```

Run the notebooks in order:

1. **01 — Data understanding and EDA:** validates the source tables, reviews missingness and category distributions, and visualises the target.
2. **02 — Preparation and feature engineering:** validates joins, builds a Won/Lost target from decided opportunities, and creates a modeling table without outcome leakage.
3. **03 — Model training and evaluation:** compares a majority-class baseline with several classifiers using training-only cross-validation and a held-out test set.

The notebooks search for the CSVs under `data/raw/` and in the current/notebook directory. Run all cells from top to bottom. Generated processed data and reports are outputs, not source files.

## Modeling choices and guardrails

- Only Won and Lost opportunities are labeled; Prospecting and Engaging are not treated as losses.
- Deal stage, close value, close date, opportunity ID and account name are not model predictors.
- Preprocessing is fit inside each training fold to reduce leakage.
- The test partition is reserved for final evaluation, not model selection.
- Accuracy is reported alongside ROC-AUC, balanced accuracy, class-specific precision/recall and confusion matrices.
- A model is not recommended merely because it ranks first among weak candidates.
- This is retrospective classification, not a point-in-time production system. The data does not provide full snapshots of what was known at each stage of a deal.

## Business metric definitions

- **Win rate:** Won / (Won + Lost); open opportunities are excluded.
- **Won revenue:** sum of `close_value` for Won opportunities.
- **Net price difference:** sum of `close_value - suggested retail price` for matched Won deals. This is not profit or margin.
- **Quarterly trends:** grouped by close date within the source period.

## Next step

Collect or engineer reliable features available before the prediction point—such as lead source, sales activities, proposal/demo milestones or competitor information—then repeat the evaluation with a time-aware validation strategy if timestamps support it.

## License and data note

The CRM data is synthetic and is included for educational analysis. Check the original dataset's terms before redistributing data or generated artifacts. No real company performance should be inferred from these records.
