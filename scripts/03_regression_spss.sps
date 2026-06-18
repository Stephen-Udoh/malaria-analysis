* Encoding: UTF-8.
* ============================================================
* Malaria Burden & Intervention Effectiveness Analysis
* SPSS Regression Syntax — Cross-validation of Python models
* Author: Stephen Udoh
* Date: June 2026
* 
* Purpose: Replicates four OLS regression models from
* Notebook 03 using identical dataset (351 rows)
* Results compared against Python statsmodels output
* in /outputs/tables/regression_results_python.csv
* ============================================================

* ------------------------------------------------------------
* STEP 1 — Load modelling dataset
* Same 351-row dataset used in Python regression
* log_gdp and binary variables already applied
* ------------------------------------------------------------

GET DATA
  /TYPE = TXT
  /FILE = "C:\Users\HP\Desktop\malaria_analysis\data\cleaned\modelling_data_for_spss.csv"
  /ENCODING = 'UTF8'
  /DELIMITERS = ","
  /QUALIFIER = '"'
  /ARRANGEMENT = DELIMITED
  /FIRSTCASE = 2
  /VARIABLES =
    country_code A3
    year F4.0
    sub_region A10
    incidence_per_1000 F8.3
    mortality_per_100k F8.3
    itn_coverage_pct F8.3
    irs_deployed F1.0
    act_deployed F1.0
    log_gdp F8.3
    urban_pct F8.3.

EXECUTE.

* ------------------------------------------------------------
* STEP 2 — Variable labels for clean output
* ------------------------------------------------------------

VARIABLE LABELS
    incidence_per_1000 'Malaria Incidence (per 1,000)'
    mortality_per_100k 'Malaria Mortality (per 100,000)'
    itn_coverage_pct   'ITN Coverage (%)'
    irs_deployed       'IRS Deployed (binary)'
    act_deployed       'ACT Deployed (binary)'
    log_gdp            'Log GDP per Capita'
    urban_pct          'Urban Population (%)'.

EXECUTE.

* ------------------------------------------------------------
* STEP 3 — Descriptive statistics
* Verify dataset matches Python modelling dataset
* ------------------------------------------------------------

DESCRIPTIVES VARIABLES = 
    incidence_per_1000 mortality_per_100k
    itn_coverage_pct irs_deployed act_deployed
    log_gdp urban_pct
  /STATISTICS = MEAN STDDEV MIN MAX.

* ------------------------------------------------------------
* MODEL 1 — Unadjusted ITN effect on incidence
* Baseline model — no controls
* Expected: positive coefficient due to targeting bias
* ------------------------------------------------------------

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA CI(95)
  /CRITERIA = PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT incidence_per_1000
  /METHOD = ENTER itn_coverage_pct
  /SAVE RESID PRED.

* ------------------------------------------------------------
* MODEL 2 — Fully adjusted ITN effect on incidence
* Controls: IRS, ACT, log GDP, urban population
* Primary model for research question
* ------------------------------------------------------------

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA CI(95) ZPP
  /CRITERIA = PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT incidence_per_1000
  /METHOD = ENTER itn_coverage_pct irs_deployed 
            act_deployed log_gdp urban_pct.

* ------------------------------------------------------------
* MODEL 3 — Fully adjusted ITN effect on mortality
* Same predictors as Model 2 — different outcome
* ACT expected stronger here than Model 2
* ------------------------------------------------------------

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA CI(95) ZPP
  /CRITERIA = PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT mortality_per_100k
  /METHOD = ENTER itn_coverage_pct irs_deployed 
            act_deployed log_gdp urban_pct.

* ------------------------------------------------------------
* MODEL 4 — Regional sensitivity check
* Adds sub_region as categorical control
* Tests whether regional factors confound results
* West Africa as reference category
* ------------------------------------------------------------

* Create dummy variables for sub_region
* West Africa = reference category (omitted)

DO IF (sub_region = 'East').
  COMPUTE region_east = 1.
ELSE.
  COMPUTE region_east = 0.
END IF.

DO IF (sub_region = 'Central').
  COMPUTE region_central = 1.
ELSE.
  COMPUTE region_central = 0.
END IF.

EXECUTE.

VARIABLE LABELS
    region_east    'East Africa (vs West — reference)'
    region_central 'Central Africa (vs West — reference)'.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA CI(95) ZPP
  /CRITERIA = PIN(.05) POUT(.10)
  /NOORIGIN
  /DEPENDENT incidence_per_1000
  /METHOD = ENTER itn_coverage_pct irs_deployed
            act_deployed log_gdp urban_pct
            region_east region_central.

* ------------------------------------------------------------
* STEP 4 — Save updated syntax file reminder
* Run File > Save after executing to preserve any edits
* Output automatically saved to regression_results_spss.spv
* ------------------------------------------------------------
