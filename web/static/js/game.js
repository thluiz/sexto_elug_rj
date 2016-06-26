
var game = function(socket) {
	var current_id = makeid();

	socket.connect()
	var channel = socket.channel("spaceship:lobby", { id: current_id })
	channel.join()
		.receive("ok", resp => { console.log("Joined successfully", resp) })
		.receive("error", resp => { console.log("Unable to join", resp) })

	var spaceship;
	var timer = 0;
	var interval = 1;
	var entities = [];

	var game = new Phaser.Game(800, 600, Phaser.AUTO, 'phaser-example',
		{ preload: preload, create: create, update: update, render: render });

	function add_entity(st) {		
		var ent = game.add.sprite(st.x, st.y, 'spaceship');
		ent.x = st.x;
		ent.y = st.y;
		ent.id = st.id;
		ent.rotation = st.r;
		
		addFlyAnimation(ent);
		entities[entities.length] = ent;	
	};

	function update_entity(st) {
		var entity = find_entity(st);
		entity.x = st.x;
		entity.y = st.y;
		entity.rotation = st.r;
	}

	function find_entity(st) {
		var len = entities.length;
		for(var i = 0; i < len; i++) {
			if(entities[i].id == st.id) {
				return entities[i];
			}			
		}

		return null;
	}

	function entity_exist(st) {
		return find_entity(st) != null;
	}

	function create_or_update(st) {
		if(!entity_exist(st)) {
			add_entity(st);
		} else {
			update_entity(st);
		}
	}

	function update_state(state_objects) {
		for(var st in state_objects) {
			var e = state_objects[st];
			if(e.id != current_id) { 
				create_or_update(e);
			} else {
				update_player(e);		
			}
		}
	}

	function update_player(status) {

	}

	function preload() {
		game.load.atlasJSONHash('spaceship', '/images/SpaceShip003.png', '/images/SpaceShip003/anim.json');
	}

	function create() {
		game.physics.startSystem(Phaser.Physics.ARCADE);

		spaceship = game.add.sprite(game.world.centerX, game.world.centerY, 'spaceship');	

		addFlyAnimation(spaceship);

		game.physics.arcade.enable(spaceship);
		channel.on("update_state", update_state);
	}

	function addFlyAnimation(target) {
		target.anchor.setTo(0.5, 0.5);
		target.animations.add('fly');
		target.animations.play('fly', 15, true);
	}

	function update () {
		//  If the sprite is > 8px away from the pointer then let's move to it
		if (game.physics.arcade.distanceToPointer(spaceship, game.input.activePointer) > 8) {
	        //  Make the object seek to the active pointer (mouse or touch).
	        game.physics.arcade.moveToPointer(spaceship, 100);
	    } else {
	        //  Otherwise turn off velocity because we're close enough to the pointer
	        spaceship.body.velocity.set(0);
	    }

	    spaceship.rotation = 4.6 /* ??? */ + game.physics.arcade.angleToPointer(spaceship);
	    timer++;
	}

	function render() {
		//console.log(spaceship);
		game.debug.spriteInfo(spaceship, 32, 100);

		if(timer % interval == 0) {
			timer = 0;
			channel.push("update_player", {
				id: current_id,
				x: spaceship.x,
				y: spaceship.y,
				r: spaceship.rotation
			});		
		}    
	}

	function makeid() {
		var text = "";
		var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

		for( var i=0; i < 5; i++ )
			text += possible.charAt(Math.floor(Math.random() * possible.length));

		return text;
	}
}

export default game