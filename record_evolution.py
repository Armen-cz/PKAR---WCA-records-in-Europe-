import pandas as pd
import csv
import matplotlib.pyplot as plt

def date_to_float(year, month, day):
    year = int(year)
    year += float((month-1)/12) + float((day-1)/31)/12
    return year

folder_location = "../WCA_export_v2_065_20260306T000015Z.tsv/"

df = pd.read_csv(
    f"{folder_location}best_dates_comma.csv",
    sep=",",
    engine="python",
    quoting=csv.QUOTE_NONE,
    on_bad_lines="skip"
)

df.reset_index(drop=True)

best_timelines = {"333": [],
                  "444": [],
                  "333bf": [],
                  "minx": [],
                  "sq1": []}

for _, row in df.iterrows():
    
    event = row["event_id"]
    
    if event not in best_timelines:
        continue
    
    date = date_to_float(row["year"], row["month"], row["day"])
    best = row["best"]/100

    if best > 80:
        continue
    
    if not best_timelines[event]:
        best_timelines[event].append((date, best))
        continue
    
    if best < best_timelines[event][-1][1]:
        best_timelines[event].append((date, best))

colors = ['#d81326', '#ff8000','#ffea00', '#02bd17','#0072d1',]
    
label_map = {
    "333": "3x3x3",
    "444": "4x4x4",
    "333bf": "3x3x3 Blindfolded",
    "minx": "Megaminx",
    "sq1": "Square-1"
}

events = ["333", "444", "333bf", "minx", "sq1"]

plt.rcParams['font.family'] = 'Arial'   # default, safe
plt.rcParams['font.size'] = 12

plt.figure(figsize=(6.8,4.3))
for i, event in enumerate(events):
    dates = [x[0] for x in best_timelines[event]]
    bests = [x[1] for x in best_timelines[event]]
    plt.step(dates, bests, where="post", label=label_map[event], color=colors[i])
    plt.scatter(dates, bests, s=15, color=colors[i])
    
plt.legend()
plt.show()




