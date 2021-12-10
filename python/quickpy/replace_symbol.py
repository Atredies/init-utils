path_to_file = "<PATH/TO/CSV>"
replaced_symbol = ';'
replaced_with = ','

with open(path_to_file, 'rw') as file:
    new_lines = ''.join(word for word in file).replace(replaced_symbol, replaced_with)
    file.writelines(new_lines)