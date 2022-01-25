extends Node

# TODO: move to a spreadsheet (CSV file)

var block_info = {
	'block-rock': {
		'min_strength': 5
	},
	'block-tree-1': {
		'min_strength': 1
	},
	'block-tree-2': {
		'min_strength': 1
	},
	'block-tree-3': {
		'min_strength': 1
	},
	'block-btree-1': {
		'min_strength': 2
	},
	'block-btree-2': {
		'min_strength': 2
	},
	'block-btree-3': {
		'min_strength': 2
	},
}

var tool_info = {
	'Hands': {
		'name': 'Hands',
		'strength': 1,
		'cost': 0
	},
	'AxeTool': {
		'name': 'AxeTool',
		'strength': 2,
		'cost': 3
	},
	'PickaxeTool': {
		'name': 'PickaxeTool',
		'strength': 5,
		'cost': 10
	},
}

var item_info = {
	'item-flower-blue': {
		'value': 1
	},
	'item-flower-pink': {
		'value': 2
	},
	'item-flower-yellow': {
		'value': 3
	},
	'item-star': {
		'value': 5
	}
}
