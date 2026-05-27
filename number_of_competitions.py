import pandas as pd
import csv
import matplotlib.pyplot as plt

folder_location = "../WCA_export_v2_065_20260306T000015Z.tsv/"

df = pd.read_csv(
    f"{folder_location}competition_year_continent.csv",
    sep="\t",
    engine="python",
    quoting=csv.QUOTE_NONE,
    on_bad_lines="skip"
)

df.reset_index(drop=True)
competition_count = {}
it = 1
for _, row in df.iterrows():
    continent = row["continent"]
    year = row["year"]

    if year == 1982 or continent == "_Multiple Continents":
        continue
    
    if continent not in competition_count:
        competition_count[continent] = {}

    if year not in competition_count[continent]:
        competition_count[continent][year] = 0

    competition_count[continent][year] += 1

plt.figure(figsize=(10,6))
for continent in competition_count:
    competition_count[continent] = dict(sorted(competition_count[continent].items(), key=lambda item: item[0]))
    plt.plot(list(competition_count[continent].keys()), list(competition_count[continent].values()), label=continent.lstrip("_"))
    
plt.legend()
plt.show()
