import pandas as pd
import numpy as np
import os

in_dir = '/Users/jasonrussell/Documents/INPUTS/fslong_A001'
out_dir = '/Users/jasonrussell/Documents/OUTPUTS/fslong_A001'

if not os.path.exists(out_dir):
	os.mkdir(out_dir)
else:
	print('Directory exists, continue')

#import csv to generate qdec
scan_data_df = pd.read_csv(f'{in_dir}/Age_at_Event_and_Latency_12Nov2024.csv')

# Convert mri_latency_in_days to numeric
scan_data_df['mri_latency_in_days'] = (
	pd.to_numeric(scan_data_df['mri_latency_in_days'], errors='coerce'))

scan_data_df_e1 = scan_data_df[(scan_data_df['event_sequence'] == 1)]
scan_data_df_fu = scan_data_df[(~scan_data_df['mri_latency_in_days'].isnull())]

scan_data_df = pd.concat([scan_data_df_e1, scan_data_df_fu])
scan_data_df = scan_data_df.sort_values(by=['subject_label', 'event_sequence'])

#Sort dataframe to match  qdec cols - fsid - fsid-base - years - age
#select columns for qdec
cols = ['subject_label', 'age_at_visit', 'mri_latency_in_days', 'event_sequence']
qdec_draft = scan_data_df[cols]
qdec_draft = qdec_draft.fillna({'mri_latency_in_days': 0})

qdec_cols = ['fsid', 'fsid-base', 'years', 'age']
qdec_df = pd.DataFrame(columns=qdec_cols)

qdec_df['fsid'] = (qdec_draft['subject_label'].astype(str) + '_e' +
				   qdec_draft['event_sequence'].astype(str))
qdec_df['fsid-base'] = qdec_draft['subject_label'].astype(str)
qdec_df['years'] = qdec_draft['mri_latency_in_days'].astype(int) / 365
qdec_df['age'] = qdec_draft['age_at_visit'].astype(int)

#Save as space separated table as text file
qdec_df.to_csv(path_or_buf=f'{out_dir}/long.qdec.table.dat', sep=' ', index=False)