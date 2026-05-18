' Cleanup.vbs
'
' This script deletes files from a root folder that 
' are older than a given number of days.
' Arguments:
' 1. The root folder path (absolute or relative).
' 2. The number of days beyond which the files and subfolders are deleted.
' 3. (optional) Also delete subfolders (true or false, default: false).
' 4. (optional) The specific extension of files to delete (e.g. "csv").
'
' Author: Romain Guay, Taleo Corporation

Dim fso, f, fc, ext, days, folder, args, arrExclude
Set args = WScript.Arguments

' The folder path (absolute or relative).
folder = args(0)

' The number of days beyond which the files get deleted.
days = CInt(args(1))

' The recursive flag (include subfolders).
If (args.Count > 2) Then
	recursive = args(2)
End If 

' The extension of the files to delete.
If (args.Count > 3) Then
	ext = args(3)
End If 

' Create a FileSystemObject.
Set fso = CreateObject("Scripting.FileSystemObject")

' Perform the deletion of files.
Set fc = fso.GetFolder(folder).Files
For Each f in fc
	If (ext = "" Or fso.GetExtensionName(f.Name) = ext) Then
		If (f.DateLastModified < (Date() - days)) Then 
			WScript.Echo("Deleting " & f.Path)
			f.Delete
		End If
	End If
Next

' Perform the deletion of subfolders.
Set fc = fso.GetFolder(folder).SubFolders
If (recursive = "true") Then
	For Each f in fc
		If (f.DateLastModified < (Date() - days)) Then 
			WScript.Echo("Deleting " & f.Path)
			f.Delete
		End If
	Next
End If

