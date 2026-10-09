# Business Analysis Report

## Executive summary

This project analyzes a synthetic B2B CRM pipeline using MySQL. The analysis covers sales team performance, sales agent performance, quarterly won revenue, and product win rates. Win rate is calculated from decided opportunities (Won and Lost), excluding open pipeline stages.

The dataset contains 8,800 pipeline rows, 85 accounts, 7 products, 35 sales-team records, and 21 data-dictionary rows. Five sales-team members have no opportunities in the pipeline and therefore do not appear in opportunity-based agent rankings.

## 1. Sales team performance

### By regional office

| Region | Won deals | Won revenue | Lost deals | Win rate | Avg. won deal size | Net price difference |
|---|---:|---:|---:|---:|---:|---:|
| West | 1,438 | $3,568,647 | 811 | 63.94% | $2,481.67 | -$15,275 |
| Central | 1,629 | $3,346,293 | 975 | 62.56% | $2,054.20 | -$5,901 |
| East | 1,171 | $3,090,594 | 687 | 63.02% | $2,639.28 | $3,228 |

**Interpretation**
- West leads on won revenue and win rate.
- Central has the largest number of won deals, but its average won deal size is lowest.
- East has the highest average won deal size and a positive net price difference against suggested retail price.
- West's revenue lead over Central is $222,354 (about 6.6% of Central's won revenue).

### By manager

| Manager | Won deals | Won revenue | Lost deals | Win rate | Avg. won deal size | Net price difference |
|---|---:|---:|---:|---:|---:|---:|
| Melvin Marxen | 882 | $2,251,930 | 536 | 62.20% | $2,553.21 | $3,229 |
| Summer Sewald | 828 | $1,964,750 | 459 | 64.34% | $2,372.89 | -$12,066 |
| Rocco Neubert | 691 | $1,960,545 | 422 | 62.08% | $2,837.26 | $3,913 |
| Celia Rouche | 610 | $1,603,897 | 352 | 63.41% | $2,629.34 | -$3,209 |
| Cara Losch | 480 | $1,130,049 | 265 | 64.43% | $2,354.27 | -$685 |
| Dustin Brinkmann | 747 | $1,094,363 | 439 | 62.98% | $1,465.01 | -$9,130 |

**Interpretation**
- Melvin Marxen has the highest won revenue among managers in this result.
- Cara Losch has the highest manager win rate in this table (64.43%).
- Rocco Neubert has the highest average won deal size ($2,837.26).
- Net price difference is a comparison to suggested retail price only; it does not measure profit or establish that a discount was given.

## 2. Sales agent performance

The agent analysis uses total opportunities, won/lost/open opportunities, won revenue, win rate, average won deal size, net price difference, and a requested category:
- **Poor:** win rate below 60%
- **Average:** win rate from 60% through 65%, inclusive
- **Good:** win rate above 65%

Previously reviewed results identified Darcel Schlecht as the highest-revenue agent ($1,153,214), Hayden Neloms as the highest-win-rate agent (70.39%), and Lajuana Vencill as the lowest-win-rate agent (54.98%). These are analysis outputs to re-run against the committed SQL before treating them as a final audited scorecard. Opportunity records without a usable agent assignment may not be represented in the agent-level aggregate.

## 3. Quarterly trends

| Quarter | Won deals | Won revenue | Revenue change vs. prior quarter |
|---|---:|---:|---:|
| 2017 Q1 | 531 | $1,134,672 | — |
| 2017 Q2 | 1,254 | $3,086,111 | +171.98% |
| 2017 Q3 | 1,257 | $2,982,255 | -3.37% |
| 2017 Q4 | 1,196 | $2,802,496 | -6.03% |

**Interpretation**
- Won revenue rises sharply from Q1 to Q2.
- Revenue declines in both Q3 and Q4 after the Q2 peak.
- Won deal volume is highest in Q3, while won revenue is highest in Q2, suggesting deal size/mix also matters.
- The available dataset covers 2017; the year is explicitly set in the query because the source data is from that year.

## 4. Product win rates

Win rate is Won / (Won + Lost), with open opportunities excluded.

| Product | Won deals | Lost deals | Win rate |
|---|---:|---:|---:|
| MG Special | 793 | 430 | 64.84% |
| GTX Plus Pro | 479 | 266 | 64.30% |
| GTX Basic | 915 | 521 | 63.72% |
| GTX Pro | 729 | 418 | 63.56% |
| GTX Plus Basic | 653 | 398 | 62.13% |
| MG Advanced | 654 | 430 | 60.33% |
| GTK 500 | 15 | 10 | 60.00% |

**Interpretation**
- MG Special has the highest observed win rate in this table.
- GTK 500's rate is based on only 25 decided opportunities, so it is less stable and should not be compared as confidently as higher-volume products.
- MG Advanced has the lowest win rate among products with substantial decided volume in this table and may warrant further investigation.
- These figures describe conversion among decided opportunities, not product profitability.

## Important limitations

- This is synthetic CRM data, not evidence of real-world company performance.
- `sales_price` is suggested retail price; net price difference must not be described as profit, margin, or confirmed discount.
- Some opportunities have missing account values.
- The raw product label `GTXPro` does not exactly match `GTX Pro` in the product reference table. Analysis normalizes the spelling without changing the source.
- Re-run the SQL script in MySQL to refresh all tables and validate the figures before using them in a formal presentation.
