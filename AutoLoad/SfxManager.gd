extends Node

var loader: = ResourceAsyncLoader.new()											# Instance of resource async loader

@export var start_player_count: int = 3											# Starting amount of AudioStreamPlayers
@export var bus_name: String = 'SFX'										# Name of the bus sample players will be aassigned to, if wrong defaults to Master
@export var sample_collection: Array[AudioStream]								# If added in scene, can preload from Inspector
var sample_dictionary: = {}														# Holds loaded samples

@export var retrigger_time: float = 1.0/60.0*2							# Choose time when same sample can be triggered again
@onready var players: = get_children()
@onready var free_players: = players												# List of AudioStreamPlayer not playing sounds
var active_players: = {}														# List of AudioStreamPlayer playing samples

func add_players(value:int)->void:
	for i in value:
		var player: = AudioStreamPlayer.new()									# Create new player
		player.bus = bus_name													# Must have an existing audio bus name
		players.append(player)
		add_child(player)

func _ready():																	# Add to database all samples preloaded in the Inspector
	for i in sample_collection.size():
		var sample:AudioStreamOggVorbis = sample_collection[i]						# RefCounted sample
		sample_dictionary[sample.get_path().get_file().get_basename()] = i		# Create entry with file name to reference index in array
	add_players(start_player_count)												# Add some players to start with

func player_play(sample_name, _player_id):
	play(sample_name)

func play(sample_name:String)->void:
#	print("playing %s"%sample_name)
	if active_players.has(sample_name):											# Same sample is already playing
		var player:AudioStreamPlayer = active_players[sample_name]
		if player.get_playback_position() > retrigger_time:						# Checks if same sample has played at least certain length
			player.play()
	else:
		if !free_players.is_empty():												# There are un-active players
			var player:AudioStreamPlayer = free_players.pop_back()
			active_players[sample_name] = player
			player.stream = sample_collection[ sample_dictionary[sample_name] ]
			player.play()
			player.connect("finished", Callable(self, "sample_finished").bind(sample_name))
		else:
			print("not enough audio players - creating new")
			var player: = AudioStreamPlayer.new()								# Create new player
			player.bus = bus_name												# Must have an existing audio bus name
			add_child(player)
			active_players[sample_name] = player
			player.stream = sample_collection[ sample_dictionary[sample_name] ]
			player.play()
			player.connect("finished", Callable(self, "sample_finished").bind(sample_name))

func sample_finished(sample_name:String)->void:									# Triggered when player is finished sample and not retriggered while playing.
	var player:AudioStreamPlayer = active_players[sample_name]
	player.disconnect("finished", Callable(self, "sample_finished"))
	active_players.erase(sample_name)
	free_players.append(player)
