Extract = (input) ->
	input: input
	
	s2ab: (s) ->
		if typeof ArrayBuffer != 'undefined'
			buf = new ArrayBuffer(s.length)
			view = new Uint8Array(buf)
			i = 0
			while i != s.length
				view[i] = s.charCodeAt(i) & 0xFF
				++i
			buf
		else
			buf = new Array(s.length)
			i = 0
			while i != s.length
				buf[i] = s.charCodeAt(i) & 0xFF
				++i
			buf

	output_formats: {
		xlsx: {
			bookType: "xlsx"
			fileExt: "xlsx"
			container: "ZIP"
			sheets: "multi"
			description: "Excel 2007 + XML Format"
			options: {}
			process: null
		}
		xlsm: {
			bookType: "xlsm"
			fileExt: "xlsm"
			container: "ZIP"
			sheets: "multi"
			description: "Excel 2007 + Macro XML Format"
			options: {}
			process: null
		}
		xlsb: {
			bookType: "xlsb"
			fileExt: "xlsb"
			container: "ZIP"
			sheets: "multi"
			description: "Excel 2007 + Binary Format"
			options: {}
			process: null
		}
		biff2: {
			bookType: "biff2"
			fileExt: "xls"
			container: "none"
			sheets: "single"
			description: "Excel 2.0 Worksheet Format"
			options: {},
			process: null
		}
		xlml: {
			bookType: "xlml"
			fileExt: "xls"
			container: "none"
			sheets: "multi"
			description: "Excel 2003-2004 (SpreadsheetML)"
			options: {}
			process: null
		}
		# needs <?mso-application progid="Excel.Sheet"?> header
		xlml_xml: {
			bookType: "xlml"
			fileExt: "xml"
			container: "none"
			sheets: "multi"
			description: "Excel 2003 XML"
			options: {}
			process: (input) ->
				return input.replace(
					'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
					'<?xml version="1.0" encoding="UTF-8" standalone="yes"?><?mso-application progid="Excel.Sheet"?>'
				)
		}
		ods: {
			bookType: "ods"
			fileExt: "ods"
			container: "ZIP"
			sheets: "multi"
			description: "OpenDocument Spreadsheet"
			options: {}
			process: null
		}
		fods: {
			bookType: "fods"
			fileExt: "fods"
			container: "none"
			sheets: "multi"
			description: "Flat OpenDocument Spreadsheet"
			options: {}
			process: null
		}
		csv: {
			bookType: "csv"
			fileExt: "csv"
			container: "none"
			sheets: "single"
			description: "Comma Separated Values"
			options: {}
			process: null
		}
		scsv: {
			bookType: "csv"
			fileExt: "csv"
			container: "none"
			sheets: "single"
			description: "Semicomma Separated Values"
			options: {
				FS: ";"
			}
			process: null
		}
		tsv: {
			bookType: "csv"
			fileExt: "tsv"
			container: "none"
			sheets: "single"
			description: "Tab Separated Values"
			options: {
				FS: "\t"
			}
			process: null
		}
		txt: {
			bookType: "txt"
			fileExt: "txt"
			container: "none"
			sheets: "single"
			description: "UTF-16 Unicode Text"
			options: {}
			process: null
		}
		sylk: {
			bookType: "sylk"
			fileExt: "sylk"
			container: "none"
			sheets: "single"
			description: "Symbolic Link"
			options: {}
			process: null
		}
		html: {
			bookType: "html"
			fileExt: "html"
			container: "none"
			sheets: "single"
			description: "HTML Document"
			options: {},
			process: null
		}
		dif: {
			bookType: "dif"
			fileExt: "dif"
			container: "none"
			sheets: "single"
			description: "Data Interchange Format"
			options: {}
			process: null
		}
		prn: {
			bookType: "prn"
			fileExt: "prn"
			container: "none"
			sheets: "single"
			description: "Lotus Formatted Text"
			options: {}
			process: null
		}
		json: {
			bookType: null
			fileExt: "json"
			container: "none"
			sheets: "multiple"
			description: "JavaScript Object Notation"
			options: {}
			process: (input) ->
				return JSON.stringify(input, true, 4)
		}
		json_min: {
			bookType: null
			fileExt: "json"
			container: "none"
			sheets: "multiple"
			description: "JavaScript Object Notation (minified)"
			options: {}
			process: (input) ->
				return JSON.stringify(input)
		}
		xml: {
			bookType: null
			fileExt: "xml"
			container: "none"
			sheets: "multiple"
			description: "Extensible Markup Languague"
			options: {}
			process: (input) ->
				return (new X2JS()).json2xml_str(input)
		}
	}
	
	export: (bookType = "xlsx", fn = "extract") ->
		# type handling for xls
		# if type == "xls"
		# 	bookType = "biff2"
		# else
		# 	bookType = type
		type = this.output_formats[bookType]['fileExt']
		
		# file
		wb = {
			"SheetNames": []
			"Sheets": {}
		}

		# add sheets
		for sheet_name, data of this.input
			# add sheet name
			wb.SheetNames.push(sheet_name)
			
			# add sheet data
			switch Guts.getDataType(data)
				when Guts.types.selector
					wb.Sheets[sheet_name] = XLSX.utils.table_to_sheet(document.querySelector(data))
				when Guts.types.arrayofarrays
					wb.Sheets[sheet_name] = XLSX.utils.aoa_to_sheet(data)
				when Guts.types.json
					wb.Sheets[sheet_name] = XLSX.utils.json_to_sheet(data)
				else
					throw new Exception("Unknown input format.")

		# generate binary
		temp_type = this.output_formats[bookType]['bookType']
		if !!temp_type
			wbout = XLSX.write(
				wb,
				Object.assign(
					{
						bookType: temp_type
						bookSST: true
						type: 'binary'
					},
					this.output_formats[bookType]['options']
				)
			)
		else
			wbout = wb
		
		# after file generated, process it
		process = this.output_formats[bookType]['process']
		if Guts.isFunction(process)
			wbout = process(wbout)
		
		
		# export
		fname = fn + "." + this.output_formats[bookType]['fileExt']
		try
			saveAs new Blob([ this.s2ab(wbout) ], type: 'application/octet-stream'), fname
		catch e
			if typeof console != 'undefined'
				console.log e, wbout
		return wbout
		
window.Extract = Extract
