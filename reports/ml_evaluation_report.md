# Win/loss modeling — evaluation summary

## Decision

**No model is recommended from the current feature set.**

The initial test baseline achieved 63.14% accuracy by predicting the majority class. Logistic Regression, Random Forest and XGBoost achieved approximately 60.7–62.8% test accuracy, with ROC-AUC scores around or below 0.50. These results do not establish useful discrimination between Won and Lost opportunities.

Exploratory comparisons with additional tree ensembles did not demonstrate a consistent improvement across cross-validation and held-out evaluation.

## What this means

The result is not evidence that a more complex algorithm is automatically needed. It suggests the current features—largely product, account profile and sales assignment—may not contain enough stable signal for this task. Accuracy alone is misleading when a majority-class baseline is already strong.

## Limitations

This is retrospective analysis of completed synthetic CRM records, not a point-in-time prediction system. The results should not be used to score live deals or make decisions about sales staff.

## Next step

Add legitimate information captured before a defined prediction point, such as lead source, sales activities, proposal/demo milestones and competitor details. Repeat evaluation with leakage controls and, where timestamps permit, a temporal hold-out.
