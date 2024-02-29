import os
import glob

app_data_dir = os.environ['LOCALAPPDATA']
directory_relative = r"Packages\Microsoft.WindowsNotepad_*\LocalState\TabState"

full_path = os.path.join(app_data_dir, directory_relative)
list_of_bin_files = glob.glob(os.path.join(full_path, '*.bin'))

for full_filepath in list_of_bin_files:
	if full_filepath.endswith('.0.bin') or full_filepath.endswith('.1.bin'):
		continue

	print("="*60)
	filename = os.path.basename(full_filepath)
	with open(full_filepath, 'rb') as filp:
		contents = filp.read()

		print(f"{filename}")
		magic_bytes = contents[0:3]
		is_saved_file = contents[3]
		print(f"{is_saved_file=}")

		if is_saved_file:
			length_of_filename = contents[4]
			print (f"{length_of_filename}")

			filename_ending = 5+length_of_filename*2
			original_filename = contents[5:filename_ending]
			original_filename = original_filename.decode('utf-16')
			print(f"{original_filename}")

		else:
			filename_ending = 0

		delimeter_start = contents[filename_ending:].index(b"\x00\x01")
		delimeter_end = contents[filename_ending:].index(b"\x01\x00\x00\x00")

		delimeter_start += filename_ending
		delimeter_end += filename_ending
		file_marker = contents[delimeter_start+2:delimeter_end]
		file_marker = file_marker[:len(file_marker)//2]

		original_file_contents = contents[delimeter_end+4+len(file_marker):-5]
		original_file_contents = original_file_contents.decode('utf-16')
		print(original_file_contents)
