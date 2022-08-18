-- rereferene from https://gist.github.com/pnbrown/e100232b0df22dd497d19a4b69941836
tell application "Finder"
	-- get the full location path of current folder, system needs it
	get path to me
	set current_dir to container of the result
	set current_dir_posix to (POSIX path of (current_dir as alias))
	
	-- ask for csv file name
	display dialog "Input csv file name plz. (without .csv suffix)." default answer ""
	set csv_file_name to (text returned of the result)
	
	-- join the full location path of current folder and construct the full file name
	set csv_file_in_full_path to (current_dir_posix & csv_file_name & ".csv")
	-- now `read` command can correctly locate the file as a whole text
	-- `paragraphs` breaks the text into a list of rows
	set csv_rows to paragraphs of (read csv_file_in_full_path as «class utf8»)
	-- this line is so hard to explain: temporarily save the system-wise text delimiters. and we are going to restore it to system at the end of program
	set {the_original_text_delimiter_of_system, my text item delimiters} to {my text item delimiters, ","}
	
	set current_number_of_row to 1
	-- some csv file ends with a empty line and some not, in case of empty line at the end of file, the line will be parsed as {}
	set empty_cell_list to {}
	repeat with each_row in csv_rows
		-- `text items of` parse a row into a list of cell values
		set cells to (text items of each_row)
		-- we do no want the first row (headers)
		if current_number_of_row > 1 and cells is not empty_cell_list then
			set {oldName, newName} to cells
			
			tell application "System Events"
				if exists file (current_dir_posix & newName) then
					display dialog "Cannot rename " & oldName & " to " & newName & " Cuz another file with the same name already exists"
					exit repeat
				end if
			end tell
			
			tell application "System Events"
				if exists file (current_dir_posix & oldName) then
					set name of file oldName of folder current_dir_posix to newName
				else
					display dialog "File: " & oldName & " do not exists."
					exit repeat
				end if
			end tell
		end if
		set current_number_of_row to (current_number_of_row + 1)
	end repeat
	set my text item delimiters to the_original_text_delimiter_of_system
end tell
