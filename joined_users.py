import pandas as pd
import csv
import matplotlib.pyplot as plt

folder_location = "../WCA_export_v2_065_20260306T000015Z.tsv/"

df = pd.read_csv(
    f"{folder_location}person_year_continent.csv",
    sep="\t",
    engine="python",
    quoting=csv.QUOTE_NONE,
    on_bad_lines="skip"
)

"""
df.reset_index()
competitor_count = {}
it = 1
for _, row in df.iterrows():
    year = row['wca_id'][0:4]
    it += 1
    if year not in competitor_count:
        competitor_count[year] = 1
        continue
    competitor_count[year] += 1
    
    
print(competitor_count)
plt.plot(list(competitor_count.keys()), list(competitor_count.values()))
plt.show()
"""

df.reset_index(drop=True)
competitor_count = {}
it = 1
for _, row in df.iterrows():
    continent = row["continent"]
    year = row["wca_id"][0:4]

    if year in ["1982", "2026"] or continent == "_Multiple Continents":
        continue
    
    if continent not in competitor_count:
        competitor_count[continent] = {}

    if year not in competitor_count[continent]:
        competitor_count[continent][year] = 0

    competitor_count[continent][year] += 1

plt.figure(figsize=(5,2.8))
for continent in competitor_count:
    competitor_count[continent] = dict(sorted(competitor_count[continent].items(), key=lambda item: item[0]))
    plt.plot(list(competitor_count[continent].keys()), list(competitor_count[continent].values()), label=continent.lstrip("_"))
plt.xticks([x for x in range(0, 23, 3)], [str(x) for x in range(2003, 2026, 3)],)
plt.grid(True)
# get rid of the frame
for spine in plt.gca().spines.values():
    spine.set_visible(False)



plt.legend()
plt.show()




    
