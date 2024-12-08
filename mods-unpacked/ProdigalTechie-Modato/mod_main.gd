extends Node

const MOD_ID = "ProdigalTechie-Modato"
const MOD_DIR = MOD_ID + "/"

const EXTS = [
	"ui/menus/pages/main_menu.gd",
	"ui/menus/run/character_selection.gd"
]

func _init():
	var dir = ModLoaderMod.get_unpacked_dir() + MOD_DIR
	var ext_dir = dir + "extensions/"
	ModLoaderLog.info("init", MOD_ID + ":Main")
	for ext_path in EXTS:
		ModLoaderLog.info("installing " + ext_path, MOD_ID + ":Main")
		ModLoaderMod.install_script_extension(ext_dir + ext_path)

func _ready():
	ModLoaderLog.info("ready", MOD_ID + ":Main")

