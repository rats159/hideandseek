package common

Username_Validation_Result :: enum {
	All_Good,
	Zero_Length,
	Over_32,
	Non_Ascii,
	Control_Char,
}
