# Gaming industry analysis: what decides peak concurrent players?

Kaggle notebook: https://www.kaggle.com/code/yashsobti/gaming-industry-analysis-peak-concurrent-players
Data Analytics for Managers using Python and SQL, individual case-based assessment
Yash Sobti (26PGDM095)

## Problem
A game publisher has to book servers before a launch. What overloads servers is the number of people online at the same time (peak concurrent players). This project checks how much of it can be explained by total players, Metacritic score, esports, platform, genre and trending status, and whether the Metacritic score changes the effect of total players.

## Data
`data/gaming_industry_trends.csv` from Kaggle: https://www.kaggle.com/datasets/haseebindata/gaming-industry-trends-1000-rows
1,000 rows and 11 columns, no missing values.

## Files
- `notebooks/gaming_industry_analysis.ipynb` - Python analysis (descriptive stats, EDA, charts, two regression models, comparison, interpretation) and the SQL section
- `sql/01_schema.sql` - two small lookup tables for the joins
- `sql/02_queries.sql` - 12 SQL queries
- `src/run_sql.py` - loads the csv into SQLite and runs the queries
- `outputs/figures/` - charts
- `outputs/sql/` - result of each query as csv, plus `sql_output_log.txt`

## Main results
- Each extra 1 million players adds about 0.31 million to the peak (p < 0.001). Model 1 R-squared is 0.646 (adjusted 0.639).
- Metacritic, revenue, year, esports, platform, genre and trending status are not significant.
- Model 2 adds players x Metacritic. Adjusted R-squared only goes up by 0.001, and the interaction is p = 0.042 normally but p = 0.056 with robust standard errors. I would use Model 1.
- Revenue could not be predicted from this data (R-squared about 1%), so I used peak players as the target.
- For planning, book about 30% of forecast players plus a buffer of roughly 27 million.

## Run it
```
pip install -r requirements.txt
python src/run_sql.py
jupyter notebook notebooks/gaming_industry_analysis.ipynb
```

## Limitations
The data looks synthetic. Each row is a title-platform-year record, and the unit of peak players is not stated (I assumed millions).
