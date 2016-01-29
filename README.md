# crapfilter
Chat filtering for World of Warcraft v1.12.1

# Introduction
I've tried a bunch of different addons for 1.12 and found none working or simply lacking features,
thus CrapFilter was born

# Usage
To configure the addon, use the following commands:

	/crapfilter <command> [phrase]
	/cf <command> [phrase]

Where command (and arguments where applicable) is:

	add <phrase> - Adds a phrase to the filter
	del <phrase> - Deletes a phrase from the filter
	list  - Displays the content of the filter
	stats - Shows amount of blocked messages and phrases
	reset - Resets the filter and statistics
	enable - Enables chat filtering
	disable - Disables chat filtering"

*Note that `disable` does not unload the addon from memory! Use the AddOns button on the character screen to prevent it from loading*