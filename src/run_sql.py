# Loads the csv into SQLite, runs the queries in sql/02_queries.sql and saves each result as a csv
import re, sqlite3, pathlib, pandas as pd
ROOT = pathlib.Path(__file__).resolve().parents[1]
CSV = ROOT/'data'/'gaming_industry_trends.csv'
OUT = ROOT/'outputs'/'sql'; OUT.mkdir(parents=True, exist_ok=True)

def build_db(csv=CSV, db=':memory:'):
    df = pd.read_csv(csv)
    df.columns = ['title','genre','platform','release_year','developer','revenue_musd',
                  'players_m','peak_ccu_m','metacritic','esports','trending']
    df.insert(0, 'game_id', range(1, len(df)+1))
    con = sqlite3.connect(db)
    df.to_sql('games', con, index=False, if_exists='replace')
    con.executescript((ROOT/'sql'/'01_schema.sql').read_text())
    return con

def run_queries(con):
    text = (ROOT/'sql'/'02_queries.sql').read_text()
    blocks = re.split(r'^-- (Q\d+): (.*)$', text, flags=re.M)[1:]
    for i in range(0, len(blocks), 3):
        qid, title, body = blocks[i], blocks[i+1], blocks[i+2]
        sql = '\n'.join(l for l in body.splitlines() if not l.startswith('--')).strip()
        yield qid, title, sql, pd.read_sql(sql, con)

if __name__ == '__main__':
    con = build_db()
    for qid, title, sql, res in run_queries(con):
        res.to_csv(OUT/f'{qid}.csv', index=False)
        print(f'\n=== {qid}: {title} ===\n{res.to_string(index=False)}')
