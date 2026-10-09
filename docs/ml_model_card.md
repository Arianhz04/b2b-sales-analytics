# Model card: B2B opportunity win/loss experiment

## Status

**Not recommended for operational use.** This repository documents an experiment and does not ship an endorsed prediction model.

## Intended use

Learning, portfolio demonstration and assessment of whether selected CRM attributes contain predictive signal for Won versus Lost outcomes.

## Out of scope

- Production deal scoring or revenue forecasting
- Automated sales-agent performance decisions
- Causal claims about why opportunities are won or lost
- Predictions for unresolved opportunities without a separately designed approach

## Data

Synthetic CRM sales opportunity records. The supervised population includes only completed Won and Lost opportunities. Open stages are excluded rather than relabeled.

## Evaluation

A majority-class baseline is compared with multiple classification algorithms. Model selection uses training-only cross-validation; the held-out test set is reserved for final evaluation. Metrics include accuracy and class-sensitive measures, with ROC-AUC used to assess ranking discrimination.

## Known limitations

- Initial held-out model performance did not demonstrate reliable discrimination beyond the baseline.
- Available features describe static account, product and sales assignment attributes more than the evolving sales process.
- The dataset does not provide complete point-in-time snapshots of feature availability.
- Results from synthetic data may not transfer to real sales environments.

## Recommendation

Do not deploy a model from this experiment. Collect legitimate pre-outcome sales-process features, define the prediction point and repeat validation before considering any operational use.
