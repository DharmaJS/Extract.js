<?php
	$_GET['options']['bare'] = "true";
	
	foreach(
		parse_ini_file(
			__DIR__
			.DIRECTORY_SEPARATOR
			.".."
			.DIRECTORY_SEPARATOR
			."src"
			.DIRECTORY_SEPARATOR
			.".premise"
		)['prepend']
		as $source
	) {
		Premise::partial(
			"local",
			$source
		);
		echo "\n";
	}
