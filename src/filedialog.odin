package main

import tinyfd "../libs/tinyfiledialogs"
import "core:strings"

open_file_dialog :: proc(title: cstring, filter: cstring) -> Maybe(cstring) {
	filter := filter
	rawFilename := tinyfd.openFileDialog(title, "", 1, &filter, nil, 0)

	if (rawFilename == nil) {
		return nil
	}

	return strings.clone_to_cstring(string(rawFilename))
}
