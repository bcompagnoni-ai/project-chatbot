' Multiply.vbs
'
' This script multiplies the first argument with the second one.
' Both arguments can be integer or decimal.
'
' Return: The result of the multiplication.
'
' Author: Romain Guay, Oracle Corporation

Dim args
Set args = WScript.Arguments

WScript.Echo(CDbl(args(0)) * CDbl(args(1)))