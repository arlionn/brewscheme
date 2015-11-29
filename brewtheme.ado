********************************************************************************
* Description of the Program -												   *
* This program is used to set theme values for things like backgrounds, point  *
* sizes, font sizes, etc...   The purpose is to allow the end user greater	   *
* flexibility in developing graph themes (e.g., create a ggplot2 theme with    *
* a given set of palettes and also create a theme with a more Tufte inspired   *
* set of background/size parameters). 										   *
*                                                                              *
* Data Requirements -														   *
*	  Allows users to build the property file interactively					   *
*																			   *
* System Requirements -														   *
*     none                                                                     *
*                                                                              *
* Program Output -                                                             *
*     theme-[theme file name].theme - The theme file created by the user	   *
*	  theme-[theme file name]_achromatopsia.theme - Full Colorblind version	   *
*	  theme-[theme file name]_protanopia.theme - Full Colorblind version	   *
*	  theme-[theme file name]_deuteranopia.theme - Full Colorblind version	   *
*	  theme-[theme file name]_tritanopia.theme - Full Colorblind version	   *
*                                                                              *
* Lines -                                                                      *
*     300                                                                      *
*                                                                              *
********************************************************************************
		
*! brewtheme
*! v 0.0.2
*! 29NOV2015

// Drop the program from memory if loaded
cap prog drop brewtheme

// Define program
prog def brewtheme

	// Set version to interpret under
	version 13.1
	
	// Set syntax tree
	syntax [anything(name=themefile id="Theme File Name")] [,				 ///   
						ABOvebelow(string asis) ANGLESTYle(string asis)		 ///   
						AREASTYle(string asis) ARROWSTYle(string asis)		 ///   
						AXISSTYle(string asis) BARLABELPos(string asis)		 ///   
						BARLABELSTYle(string asis) BARSTYle(string asis)	 ///   
						BYGRAPHSTYle(string asis) CLEGENDSTYle(string asis)	 ///   
						CLOCKdir(string asis) COLor(string asis)			 ///   
						COMPASS2dir(string asis) COMPASS3dir(string asis)	 ///   
						CONNECTSTYle(string asis) DOTTYPESTYle(string asis)	 ///   
						GRAPHSIze(string asis) GRAPHSTYle(string asis)		 ///   
						GRIDLINESTYle(string asis) GRIDRINGSTYle(string asis) ///   
						GRIDSTYle(string asis) GSIZE(string asis) 			 ///   
						HORIZontal(string asis) LABELSTYle(string asis)		 ///   
						LEGENDSTYle(string asis) LINEPATtern(string asis)	 ///   
						LINESTYle(string asis) LINEWidth(string asis)		 ///   
						MARGin(string asis) MEDTYPESTYle(string asis)		 ///   
						NUMSTYle(string asis) NUMTICKS(string asis)			 ///   
						PIEGRAPHSTYle(string asis) PIELABELSTYle(string asis) ///   
						PLOTREGIONSTYle(string asis) RELATIVEPos(string asis) ///   
						RELSIze(string asis) SPECial(string asis)			 ///   
						STARSTYle(string asis) SYMBol(string asis)			 ///   
						SYMBOLSIze(string asis) ORIENTSTYle(string asis)	 ///   
						TEXTBOXSTYle(string asis) TICKPosition(string asis)  ///   
						TICKSTYle(string asis) TICKSETSTYle(string asis)	 ///   
						VERTICAL(string asis) VERTICALText(string asis)		 ///   
						YESNo(string asis) ZYX2Rule(string asis) 			 ///   
						ZYX2STYle(string asis) LOADThemedata ]
						
	// Stores the root file path for theme files
	loc themeroot `c(sysdir_personal)'b/theme/theme
	
	// Preserve the current state of the data	
	preserve	
	
		// Create a brewcolors object
		mata: brewc = brewcolors()
		
		// Get the list of unique meta names
		mata: brewc.getNames(2)
		
		// Store the meta names in separate macro
		loc matanames `colornames'
			
		// Get the list of unique colors
		mata: brewc.getNames(1)
		
		// Build dataset with classes, arguments, and parameter values
		qui: themedata
		
		// Store the name of the tempfile 
		loc tmptheme `r(themefile)'
		
		// Load the tempfile
		qui: use `tmptheme', clear
		
		// Add variables to store color sight impairment transforms
		qui: g achromatopsia = ""
		qui: g protanopia = "" 
		qui: g deuteranopia = "" 
		qui: g tritanopia = "" 

		// Loop over the class names
		foreach v in `"`r(classes)'"' {
		
			// Store arguments in new locals
			loc `v'args `"`r(``v'args')'"'
			
			// If the user passed values
			if `"``v''"' != "" {
			
				// Loop over arguments
				forv i = 1/`: word count ``v''' {
				
					// Store argument
					loc indi `: word `i' of ``v'''
				
					loc arg `: word 1 of `indi''
					
					loc val `: word 2 of `indi''
					
					// Check if valid argument
					if `"`: list indivarg in `v'args'"' != "" {

						// Search for the RGB values
						mata: brewc.brewNameSearch("`val'")
							
						// Replace value with user specified value
						qui: replace value = `"`rgb'"' if 					 ///   
						classname == `"`v'"' & argname == `"`arg'"'
						
						// Loop over colorblind variables
						foreach cb in achromatopsia protanopia deuteranopia  ///   
						tritanopia {
						
							// Replace colorblind transform values
							qui: replace `cb' = "``cb''" if 				 ///   
							classname == `"`v'"' & argname == `"`arg'"'
						
						} // End Loop over transformed RGB variables
					
					} // End IF Block for valid arguments
				
				} // End Loop over arguments
			
			} // End IF Block for user supplied values
					
		} // End Loop over class names
		
		// Check for name of themefile
		if `"`themefile'"' != "" {

			// Check for directory and if not build it	
			dirfile, p(`"`c(sysdir_personal)'b/theme"') 
			
			// Write the scheme file to a location on the path
			qui: file open theme using `"`themeroot'-`themefile'.theme"', w replace
				
			// Loop over colorblind variables
			foreach cb in achromatopsia protanopia deuteranopia tritanopia {

				// Open a theme file for each of the colorblind types
				qui: file open `cb'theme using 								 ///   
				`"`themeroot'-`themefile'_`cb'.theme"', w replace
			
			} // End Loop to open color blindness theme files
			
			// Call write subroutine
			themewriter

		} // End IF BLock for writing a theme file if user specified a theme file name
		
		// If no name is passed write the default file
		else {
		
			// Check for directory and if not build it	
			dirfile, p(`"`c(sysdir_personal)'b/theme"') 
			
			// Write the scheme file to a location on the path
			qui: file open theme using `"`themeroot'-default.theme"', w replace
				
			// Loop over colorblind variables
			foreach cb in achromatopsia protanopia deuteranopia tritanopia {

				// Open a theme file for each of the colorblind types
				qui: file open `cb'theme using 								 ///   
				`"`themeroot'-default_`cb'.theme"', w replace
			
			} // End Loop to open color blindness theme files
			
			// Call write subroutine
			themewriter

		} // End else block for a default theme file
	
	// Restore the data to the original state
	restore
	
	// Check loadthemedata option
	if `"`loadthemedata'"' != "" {
	
		// Load the tempfile
		qui: use `tmptheme', clear
		
	} // End IF Block for load theme data option
	
// End Program Definition	
end

// Drop subroutine if already loaded in memory
cap prog drop themedata
	
// Subroutine to build look up dataset
prog def themedata, rclass

	// Null syntax structure
	syntax 

	// Drop data from memory
	clear 

	// Run the do file
	qui: do brewthemedata.do

	// Reserve namespace for a temporary file
	tempfile themedata

	// Get the names of the classes that can have values altered
	qui: levelsof classname if substr(classname, 1, 1) != "*", loc(classes) 

	// Return a local with the class names
	ret loc classes `classes'

	// Loop over the class names
	foreach v of loc classes {

		// Get the argument names for the classes
		qui: levelsof argname if classname == `"`v'"', loc(args) 
		
		// Return the arguments for the given class
		ret loc `v'args `args'
		
	} // End Loop over the class names

	// Save the data to a temporary file
	qui: save `themedata'.dta, replace

	// Clear those data from memory
	clear

	// Return the name of the tempfile 
	ret loc themefile `themedata'.dta

// End of the subroutine definition
end

// Drop subroutine if already loaded in memory
cap prog drop themewriter
	
// Subroutine for writing the data to a theme file
prog def themewriter

	// Null syntax structure
	syntax 

	// Loop over the observations
	forv i = 1/`c(N)' {
	
		// Combine the different variables into a single string
		loc string `: di classnm[`i'] + argnm[`i'] + value[`i']'
		
		// Write the string to the file and insert the number of new 
		// lines based on new line variable
		file write theme `"`"`string'"' `: di newlines[`i']'"' _n
		
		// Loop over the colorblindness types
		foreach cb in achromatopsia protanopia deuteranopia tritanopia {
			
			// Creates string with color bli
			loc string `: di classnm[`i'] + argnm[`i'] + `cb'[`i']'
			
			// Write to the colorblind simulated theme file
			file write `cb'theme `"`"`string'"' `: di newlines[`i']'"' _n
			
		} // End Loop over colorblind transformed theme files
			
	} // End Loop over observations
	
	// Close the open file connection
	file close theme
	
	// Loop over the colorblindness types
	foreach cb in achromatopsia protanopia deuteranopia tritanopia {
			
		// Close the theme file
		file close `cb'theme
		
	} // End loop over colorblindness type theme files
			
// End of sub routine
end

