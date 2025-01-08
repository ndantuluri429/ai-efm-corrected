# Converting CTU-UHB Data from Physionet to a CSV


### Overview:

Before running the models, you need to prepare the CTU-UHB database as a workable dataset. You can access the data from the following link: https://physionet.org/content/ctu-uhb-ctgdb/1.0.0/. The dataset is provided as a zip file containing .dat and .hea files, which include the signal data and summary notes for each record. These signals must be merged, made viewable, and converted into a CSV file in order to prepare the data for further analysis. The below is sample code used by a student to crate the merged CTU-UHB CSV file.


## General pipeline:
1. Indicate the path to the downloaded physionet files. Save as “ctu-chb-raw-data” in your repository.
2. Create the following files: ctu-raw-to-csv.py & CTU-merge-signals.py
3. Navigate to correct directory
4. Make sure to activate conda environment and that all dependencies are loaded. 
5. Run all of the scripts from part 2.

_The code snippets below are an example of how this pipeline can be used and followed. Be sure to edit the code so your file path is correctly specified._

## how to open the files
1. go to correct directory: cd /Users/nehadantuluri/PycharmProjects/ai-efm-2
2. activate environment: conda activate wfdb-env
3. run script:python view_CTU.py

## code for view_CTU.py 
_Note: This is not required, but is included for if you want to view the .dat files via matplotlib_
```
import wfdb
# Use relative path to access the .dat and .hea files
record = wfdb.rdrecord('ctu-chb-raw-data/1001')
# Print details about the record
print(record.__dict__)
# plot signals to visualize the data
wfdb.plot_wfdb(record)
```

## code for ctu-raw-to-csv.py
```
import pandas as pd
import wfdb
from os import listdir
from tqdm import tqdm

# Define paths
data_dir = '/Users/nehadantuluri/PycharmProjects/ai-efm-2/ctu-chb-raw-data/'
output_dir = '/Users/nehadantuluri/PycharmProjects/ai-efm-2/preprocessing/CTU/'

# get all records
def get_all_records():
    rec_list = []
    for file in listdir(data_dir):
        rec = file[:file.find('.')]
        try:
            rec = int(rec)
            rec_list.append(rec)
        except:
            pass
    rec_list = [str(i) for i in rec_list]
    return rec_list

# create signals database
def create_signals_database(rec):
    sample = wfdb.rdsamp(f"{data_dir}{rec}")
    df = pd.DataFrame(sample[0], columns=['FHR', 'UC'])
    df.index.name = 'seconds'
    df['PID'] = rec[:4]
    df.to_csv(f'{output_dir}{rec}_signals.csv')

# create annotation dataframe
def create_ann_dataframe(rec):
    sample = wfdb.rdsamp(f"{data_dir}{rec}")
    ann = sample[1]['comments'][1:]
    ann_dic = {}
    for a in ann:
        if '--' in a:
            ann.remove(a)
    for a in ann:
        key = a[:a.find('  ')]
        if a.find('  ') == -1:
            key = a[:a.find(' ')]
        inv = a[::-1]
        value = inv[:inv.find(' ')][::-1]
        value = float(value)
        ann_dic[key] = [value]
    df1 = pd.DataFrame.from_dict(ann_dic).T
    df1 = df1.rename(columns={0: rec})
    return df1

# append annotation dfs
def append_ann_dataframes(df, df1):
    rec = df1.columns[0]
    df[rec] = df1[rec]
    return df

# process records
df = pd.DataFrame()
for rec in tqdm(get_all_records()):
    create_signals_database(rec)
    df = append_ann_dataframes(df, create_ann_dataframe(rec))
df.to_csv(f'{output_dir}ann_db.csv')
```


## code for CTU-merge-signals-py
```
import pandas as pd
import os

# file path to individual CSV files
csv_dir = '/Users/nehadantuluri/PycharmProjects/ai-efm-2/preprocessing/CTU/'

# list all CSV files 
csv_files = [f for f in os.listdir(csv_dir) if f.endswith('_signals.csv')]

# create empty list to store DataFrames
df_list = []

# iterate over each CSV file
for file in csv_files:
    df = pd.read_csv(os.path.join(csv_dir, file))
    # Extract record identifier from the filename (e.g., '1001_signals.csv' -> '1001')
    record_id = file.split('_')[0]
    # Add a new column 'Record_ID' with the record identifier
    df['Record_ID'] = record_id
    # append df to the list
    df_list.append(df)

# concatenate all dfs in the list into one large DataFrame
merged_df = pd.concat(df_list, ignore_index=True)

# Save the merged DataFrame to a new CSV file
merged_df.to_csv('/Users/nehadantuluri/PycharmProjects/ai-efm-2/preprocessing/CTU/merged_CTU_data.csv', index=False)

print("Merging completed. The merged file is saved as 'merged_CTU_data.csv'.")
```

