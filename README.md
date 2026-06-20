# Malaria Burden & Intervention Effectiveness Analysis

A full-pipeline epidemiological analysis of malaria burden and intervention coverage across sub-Saharan Africa (2000–2024), combining SQL data engineering, statistical regression, machine learning, and time series forecasting.

## The Question

Does insecticide-treated bed net (ITN) coverage significantly reduce malaria incidence and mortality across sub-Saharan Africa? Which demographic, economic, and geographic factors moderate this relationship?

## Key Findings

- Malaria incidence declined **40%** and mortality declined **65%** across sub-Saharan Africa between 2000 and 2024 — but progress has slowed markedly since 2015
- **Economic capacity (GDP per capita)** is the strongest and most consistent predictor of lower malaria burden across every method tested — regression, machine learning, and descriptive analysis alike
- **IRS (indoor residual spraying)** shows a disproportionately strong protective effect against **mortality specifically** — confirmed independently by both OLS regression and Random Forest
- **ITN coverage shows a persistent positive association with burden** even after statistical adjustment — this reflects deliberate targeting bias (highest-burden countries received the most nets), not evidence against ITN effectiveness. Country-level data cannot resolve this; individual-level data would be required
- **Central Africa carries the highest current burden and shows zero projected improvement through 2030** under current trends — the clearest policy-relevant finding in this analysis

Full methodology and limitations are documented throughout the notebooks below.

## Data Sources

| Source | Dataset | Coverage |
|--------|---------|----------|
| WHO Global Health Observatory | Malaria incidence & mortality | 2000–2024, ~46 countries |
| WHO Global Health Observatory | ITN, IRS, ACT intervention coverage | 2015–2024 |
| World Bank Open Data | GDP per capita, urban population % | 2000–2024 |

## Methodology Overview

| Stage | Tool | Notebook |
|-------|------|----------|
| Data extraction, cleaning, transformation | SQL (MySQL) + Python | `01_data_preparation.ipynb` |
| Exploratory data analysis | Python (pandas, seaborn) | `02_exploratory_analysis.ipynb` |
| Regression analysis | Python (statsmodels) + SPSS 27 | `03_regression_analysis.ipynb` + `scripts/03_regression_spss.sps` |
| Machine learning & forecasting | Python (scikit-learn, Prophet) | `04_machine_learning.ipynb` |

Regression analysis was conducted independently in both **SPSS 27** and **Python statsmodels** on an identical dataset to validate findings across analytical environments. Coefficients were identical across both tools; standard errors differed by design (Python uses HC3 robust standard errors given confirmed heteroscedasticity). All substantive conclusions were consistent across both implementations.

### Analytical models

1. **Time series analysis** (2000–2024) — continental and sub-regional burden trends
2. **Multiple linear regression** (2015–2024) — ITN effect on incidence and mortality, adjusted for IRS, ACT, GDP, and urbanisation, with a regional sensitivity check
3. **Random Forest regression** — non-linear feature importance, cross-validated
4. **Prophet time series forecasting** — burden projections to 2030, continental and by sub-region

## Key Methodological Decisions

- **IRS and ACT coverage** were operationalised as binary variables (deployed / not deployed) due to high missingness (48% and 37% respectively) and the absence of a population denominator needed for rate conversion. This captures programme presence but not scale — documented as a limitation throughout.
- **Incidence and mortality** were retained on their original WHO scales (per 1,000 and per 100,000 respectively) rather than forced onto a common scale, since they measure different phenomena and are always analysed separately.
- **GDP per capita** was log-transformed prior to regression (skewness reduced from 2.87 to 0.66) following formal normality testing.
- **Seven low-transmission/near-elimination countries** (Botswana, Cape Verde, Algeria, Namibia, São Tomé, Eswatini, South Africa) were excluded from regression analysis, as WHO does not publish modelled ITN estimates for these settings — they fall outside the epidemiological scope of the research question.

Full decision trail and data quality audit available in [`docs/`](docs/).

## Repository Structure

```
??? data/
?   ??? raw/              Original downloaded files (WHO, World Bank)
?   ??? cleaned/          Analysis-ready datasets produced by the SQL pipeline
??? notebooks/
?   ??? 01_data_preparation.ipynb
?   ??? 02_exploratory_analysis.ipynb
?   ??? 03_regression_analysis.ipynb
?   ??? 04_machine_learning.ipynb
??? scripts/
?   ??? 03_regression_spss.sps    SPSS syntax — reproducibility proof
??? outputs/
?   ??? figures/          13 publication-quality charts
?   ??? tables/           Regression results, model comparisons, findings summary
??? docs/
?   ??? Data Auditing.txt Full data quality audit log
??? README.md
```

## Reproducing This Analysis

1. Clone this repository
2. Install dependencies: `pandas`, `numpy`, `sqlalchemy`, `mysql-connector-python`, `python-dotenv`, `matplotlib`, `seaborn`, `statsmodels`, `scikit-learn`, `prophet`
3. Create a `.env` file in the project root with your local MySQL credentials (see structure in `01_data_preparation.ipynb`)
4. Run notebooks in order — each notebook reads the outputs of the previous one from `data/cleaned/`

## Limitations

- Country-year is an ecological unit of analysis — findings describe patterns across countries, not individual-level causal effects (ecological fallacy)
- ITN's true causal effect cannot be isolated from targeting bias using country-level data alone
- A subset of WHO indicators rely on modelled rather than directly surveyed estimates, particularly for countries with limited health surveillance capacity
- Forecasts to 2030 are trend extrapolations assuming no major policy, funding, or biological disruption — not predictions of certain outcomes

## Author

Stephen Udoh — [GitHub](https://github.com/Stephen-Udoh)


