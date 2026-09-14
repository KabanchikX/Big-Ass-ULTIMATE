extends RefCounted;

const mod_info : Dictionary = {
	"name" : "Vanilla",
	"description" : "Original content",
	"version" : "1.0.0",
	"author" : "KabanchikX"
}

const mod_data : Dictionary = {
	"items": {
		0: {
			"name" : "Steel sword",
			"technical_name" : "steel_sword",
			"rareness" : "vanilla.legendary",
			"description" : "just a dull sword"
			},
		1: {
			"name" : "Candlestick",
			"technical_name" : "candlestick",
			"rareness" : "vanilla.epic",
			"description" : "just a candle"
			},
		2: {
			"name" : "Golden Revolver",
			"technical_name" : "golden_revolver",
			"rareness" : "vanilla.secret",
			"description" : "\nDAAAAMN MAN!\nTHIS ONE IS REALLY BADASS"
			},
		3: {
			"name" : "Kokushibo sword",
			"technical_name" : "kokushibo_sword",
			"rareness" : "vanilla.secret",
			"description" : "\nDAAAAMN MAN!\nTHIS ONE IS REALLY BADASS"
			},
		},
	"rareness_styles": {
			"shit" : "[color=brown]%s[/color]\n",
			"poor" : "[color=grey]%s[/grey]\n",
			"bruh" : "[color=grey]$s[/color]\n",
			"common" : "%s\n",
			"uncommon" : "[color=green]%s[/color]\n",
			"rare" : "[color=orange]%s[/color]\n",
			"legendary" : "[color=yellow][pulse freq=4.0, color=orange][shake level=6.0, rate=20.0]%s[/shake][/pulse][/color]\n",
			"epic" : "[color=pink][wave]%s[/wave][/color]\n",
			"unbelieavble" : "[aboba]\n",
			"amazing" : "[aboba]\n",
			"secret" : "[rainbow][shake level=6.0, rate=20.0]%s[/shake][/rainbow]\n",
			"special" : "[aboba]\n",
		},
	"worlds": {
		"test_place": {
			"name":"Test Place",
			"description":"Vanilla world for testing"
			},
		"main_menu": {
			"name":"Main menu",
			"description":"if you even see this, i did smth wrong probably"
		},
	}
}
