# Machine-learning methodology

## Objective

Assess whether account-profile, product and sales-assignment attributes in the completed CRM records can distinguish Won from Lost opportunities. This is an exploratory retrospective classification exercise, not a deployed sales scoring system.

## Target and population

- Positive class: `Won`
- Negative class: `Lost`
- Excluded from supervised training: `Prospecting` and `Engaging`, because their outcomes are unresolved.
- Source data is preserved. `GTXPro` is normalized to `GTX Pro` only in a derived product join key.

## Predictors and leakage controls

The model excludes `deal_stage`, realized `close_value`, `close_date`, opportunity identifiers and account names. Preprocessing is defined in a pipeline and fitted within each training fold. Features must represent information plausibly available before the outcome.

A remaining limitation is that the source data is not a set of point-in-time CRM snapshots. Even a technically clean split cannot prove that every available predictor would have been captured at a real decision time.

## Validation

Use a stratified hold-out test partition for final evaluation. Compare candidate models using cross-validation on the training partition only. Report accuracy, balanced accuracy, precision, recall, F1 and ROC-AUC, with confusion matrices and ROC/precision-recall curves where applicable.

The majority-class baseline is required. A candidate is not recommended just because it ranks first among weak models. Scores around ROC-AUC 0.50 indicate little ranking discrimination; a model below that reference on held-out data should not be described as useful.

## Interpreting the current result

The initial experiment reported 63.14% test accuracy for the majority-class baseline. The evaluated Logistic Regression, Random Forest and XGBoost models did not beat it meaningfully, and their test ROC-AUC scores were around or below 0.50. Additional tree-ensemble experiments did not establish consistent out-of-sample discrimination.

Conclusion: no model is recommended from the current feature set. This does not prove that win/loss prediction is impossible; it indicates that the tested features and validation setup did not demonstrate useful signal.

## Next experiment

Prioritize new pre-outcome information: lead source, dated customer interactions, demos, proposals, quote revisions, competitor fields and historical account context. Define a specific prediction point (for example, after qualification) and ensure every feature predates that point. If suitable timestamps exist, consider temporal validation to better approximate future use.
