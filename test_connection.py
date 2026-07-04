from sqlalchemy import create_engine
import pandas as pd

# Replace with your password
password = "root123"

engine = create_engine(
    f"mysql+pymysql://root:{password}@localhost/dealership"
)

query = "SELECT * FROM Car"

df = pd.read_sql(query, engine)

print(df)