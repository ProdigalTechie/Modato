extends Node

const MOD_ID = "ProdigalTechie-Modato"
const MOD_DIR = MOD_ID + "/"

const EXTS = [
	"main.gd",
	"ui/menus/run/character_selection.gd"
]

const TRANS = [
	"translations.en.translation"
]

func _init():
	var dir = ModLoaderMod.get_unpacked_dir() + MOD_DIR
	var ext_dir = dir + "extensions/"
	var res_dir = dir + "translations/"
	ModLoaderLog.info("installing script extensions", MOD_ID + ":Main")
	for ext_path in EXTS:
		ModLoaderMod.install_script_extension(ext_dir + ext_path)
	ModLoaderLog.info("installing translations", MOD_ID + ":Main")
	for tr_path in TRANS:
		ModLoaderMod.add_translation(res_dir + tr_path)

func _ready():
	ModLoaderLog.info("ready", MOD_ID + ":Main")

