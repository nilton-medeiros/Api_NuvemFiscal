#include "hmg.ch"
#include "hbclass.ch"

class TSQLString
	data value init "" readonly
	data valuePrevious init "" readonly
	data cargo

	method new(text) constructor
	method add(text) setget
	method empty() inline Empty(::value)
	method setValue(text) setget
end class

method new(text) class TSQLString
	if ValType(text) == "C"
		::value := text
		::valuePrevious := text
	endif
return self

method add(text) class TSQLString
	::value += text
return Nil

method setValue(text) class TSQLString
	if ValType(text) == "C"
		::valuePrevious := ::value
		::value := text
	endif
return ::value
