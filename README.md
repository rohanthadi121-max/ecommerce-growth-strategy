# E-commerce Growth Strategy | A Data-Driven Retail Case Study

> **Can a UK retailer find £1 million in incremental sales through smarter customer retention and merchandising?**

**R · Commercial analytics · Customer segmentation · Revenue diagnostics · Scenario modelling**

**Project status:** Reproducible analysis code and decision framework published. **Empirical findings pending source-data execution and validation.** The £1m objective is a *scenario target*, not realised or verified revenue.

## The business challenge

A retailer can increase revenue by attracting customers, increasing order value, improving repeat purchasing or reducing lost orders. Which levers deserve investment first? This project builds a transparent evidence-to-decision workflow: **clean transactions → measure performance → segment customers → quantify opportunities → recommend experiments**.

| Workstream | Business decision | Evidence generated |
|---|---|---|
| Revenue performance | When and where does sales performance vary? | Monthly revenue, order count and AOV |
| Product mix | Which products drive the most purchase value? | Product ranking and revenue concentration |
| Customer retention | Which customer cohorts are worth re-engaging? | Repeat-order share and RFM groups |
| Growth planning | What assumptions are needed to reach £1m? | Explicit upside scenarios and sensitivities |

## Data

**Source:** [UCI Machine Learning Repository — Online Retail II](https://archive.ics.uci.edu/dataset/502/online%2Bretail%2Bii). This is an actual UK-based online retailer's historical transactions (2009–2011), with approximately 1.07 million **line records** (not 1.07 million unique orders or customers).

**Important caveats:** Not TikTok Shop data. No visits, impressions, ad costs, acquisition channels or merchant onboarding records; therefore **conversion rate, CAC and marketing ROI cannot be measured**. Currency is treated as GBP. Cancellation handling and incomplete customer identifiers require care.

## Repository map

- [`R/analysis.R`](R/analysis.R): data ingestion, validation, purchases, monthly KPIs, products and customer segments
- [`R/growth_scenarios.R`](R/growth_scenarios.R): assumption-driven revenue opportunity sensitivity analysis
- [`report/strategy-report.md`](report/strategy-report.md): recruiter-friendly executive narrative and explicit evidence gaps
- [`docs/metric-definitions.md`](docs/metric-definitions.md): precise definitions, limitations and data checks
- [`data/README.md`](data/README.md): how to obtain the source data responsibly

## Run the analysis

1. Install **R 4.2+** and install dependencies:

```r
install.packages(c("readxl", "dplyr", "ggplot2", "lubridate", "readr", "tidyr", "stringr", "tibble"))
```

2. Download the original Excel workbook from [UCI](https://archive.ics.uci.edu/dataset/502/online%2Bretail%2Bii) and save it as **`data/online_retail_II.xlsx`**.
3. From the repository root, run:

```r
source("R/analysis.R")
source("R/growth_scenarios.R")
```

4. Review the files written into `outputs/`. Check numerical and business meaning **before publishing any finding**. Raw data and unreviewed outputs are not committed by default.

## What a strong strategy recommendation needs

A good recommendation is **quantified, testable and honest about uncertainty**. For each possible action, the final report should state:

1. **Observation:** What is actually visible in historical data?
2. **Hypothesis:** Why might the pattern be happening? (Not the same as proven causality.)
3. **Action:** What could a business team change?
4. **Success metric:** Which measurable KPI would tell us if it worked?
5. **Constraints:** Cost, operational complexity, sample limitations and attribution risks.

The `£1m` case is explicitly a **hypothetical increment**. Scenario modelling does not establish that any particular retention, cross-sell or merchandising action will deliver it.

## Next evidence milestone

- [x] Define the commercial question and reproducible analysis methodology
- [x] Implement R data-processing and KPI pipeline
- [x] Create transparent revenue-scenario analysis
- [ ] Run the complete official workbook and verify reported totals
- [ ] Publish validated findings, charts and executive recommendation
- [ ] Review attribution, representativeness and policy implications

**Disclosure:** This project was started in October 2026 and is in progress. This repository is a demonstrable analytical framework—not an assertion of earlier completion or business results.

---
*Independent portfolio case study. Not affiliated with TikTok or the original retailer.*