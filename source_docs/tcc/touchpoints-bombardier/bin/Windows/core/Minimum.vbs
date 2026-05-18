' Minimum.vbs
'
' This script returns the minimum of the first and second arguments.
' Both arguments can be integer or decimal.
'
' Return: The minimum value.
'
' Author: Romain Guay, Oracle Corporation

Dim args
Set args = WScript.Arguments

If (CDbl(args(0)) < CDbl(args(1))) Then
	WScript.Echo(args(0))
Else
	WScript.Echo(args(1))
End If
