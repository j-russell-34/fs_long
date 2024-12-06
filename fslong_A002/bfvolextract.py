
import pandas as pd
import re
import glob

in_dir = "/Users/jasonrussell/Documents/INPUTS/fslong_A002"
out_dir = "/Users/jasonrussell/Documents/OUTPUTS/fslong_A002"

columns = ['subject', 'event', 'left_basal_forebrain', 'right_basal_forebrain', 'eTIV']
bfvol_df =  pd.DataFrame(columns=columns)

# Path to the .stats file
file_path = f'{in_dir}/SUBJECTS/10001_e1.long.10001/stats/sclimbic.stats'

for file_path in sorted(glob.glob(f'{in_dir}/SUBJECTS/*.long.*/stats/sclimbic.stats')):
	if file_path.startswith('.'):
		# ignore hidden files and other junk
		continue

	# Regular expression to extract the subject_id and event
	match = re.search(r'/SUBJECTS/(\d+)_e(\d+)\.long\.\d+', file_path)

	if match:
		subject_id = match.group(1)
		event = match.group(2)
		print(f"Subject ID: {subject_id}")
		print(f"Event: {event}")
	else:
		print("Subject ID or Event not found.")

	# Initialize variables
	etiv_value = None  # To store the eTIV value
	metadata_lines = []  # To store metadata
	data_lines = []  # To store table data

	# Open and process the file
	with open(file_path, 'r') as f:
		for line in f:
			# Process metadata lines (lines starting with '#')
			if line.startswith('#'):
				metadata_lines.append(line.strip())
				# Extract the eTIV value from the 3rd commented line
				if 'eTIV' in line:
					etiv_value = float(line.split(',')[3].strip())
			else:
				# Add non-comment lines to data_lines
				data_lines.append(line.strip())

	# Convert table data into a pandas DataFrame
	columns = ['Index', 'SegId', 'NVoxels', 'Volume_mm3', 'StructName']
	data = pd.DataFrame(
	[line.split()[:4] + [' '.join(line.split()[4:])] for line in data_lines],
	columns=columns
	)

	# Ensure numeric columns are converted correctly
	data[['Index', 'SegId', 'NVoxels', 'Volume_mm3']] = data[['Index', 'SegId', 'NVoxels', 'Volume_mm3']].apply(pd.to_numeric)


	#create list with all data
	row = [subject_id, event, data.loc[data['StructName'] == 'Left-Basal-Forebrain', 'Volume_mm3'].values[0], data.loc[data['StructName'] == 'Right-Basal-Forebrain', 'Volume_mm3'].values[0], etiv_value]

	bfvol_df.loc[len(bfvol_df)] = row

print(bfvol_df)

#save the table to a CSV file
bfvol_df.to_csv(f'{out_dir}/sclimbic_vols.csv', index=False)