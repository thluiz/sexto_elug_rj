
var game = function(socket) {
	var current_id = makeid();

	socket.connect()
	var channel = socket.channel("spaceship:lobby", { id: current_id })
	channel.join()
		.receive("ok", resp => { console.log("Joined successfully", resp) })
		.receive("error", resp => { console.log("Unable to join", resp) })

	var spaceship;
	var timer = 0;
	var interval = 5;
	var entities = [];
	var bullets;
	var nextFire = 0;
	var fireRate = 200;
	var cleanUpInterval = 1000;
	var current_state;


	var game = new Phaser.Game(800, 600, Phaser.AUTO, 'phaser-example',
		{ preload: preload, create: create, update: update, render: render });

	function add_entity(st) {
		if(st.player == current_id) {
			return;
		}

		var ent = (st.type == 0 ? 
					game.add.sprite(st.x, st.y, 'spaceship')
					:game.add.sprite(st.x, st.y, 'blue_bullet'));
		ent.x = st.x;
		ent.y = st.y;
		ent.id = st.id;
		ent.rotation = st.r;
		
		addFlyAnimation(ent);

		entities[entities.length] = ent;	
	};

	function update_entity(st, entity) {		
		/* game.add.tween(entity).to({
			x:st.x,
			y:st.y, 
			rotation: st.r
		}, 3); */

		game.add.tween(entity).to({ x: st.x, y: st.y, rotation: st.r }, 
						3, Phaser.Easing.Cubic.In, true);

		//entity.x = st.x;
		//entity.y = st.y;
		//entity.rotation = st.r;
	}

	function find_entity(st) {				
		return _.first(_.where(entities, { id: st.id }));
	}

	function create_or_update(st) {
		var ent = find_entity(st);

		if(ent == null) {
			add_entity(st);
		} else {
			update_entity(st, ent);
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
		current_state = state_objects;
	}

	function remove_not_found() {
		var players = _.where(entities, { type: 0 });

		_.each(players, function(player) {			
			var ent = _.findWhere(current_state, { id: player.id });
			if(ent != null) { 								
				return;
			}

			entities = _.without(entities, _.findWhere(entities, {id: player.id }));
		});

		setTimeout(remove_not_found, cleanUpInterval);
	}

	function update_player(status) {

	}

	function preload() {
		game.load.image('blue_bullet', '/images/bullet/blue.png');
		game.load.image('green_bullet', 'images/bullet/green.png');
		game.load.atlasJSONHash('spaceship', '/images/SpaceShip003.png', '/images/SpaceShip003/anim.json');
	}

	function create() {
		game.physics.startSystem(Phaser.Physics.ARCADE);
		game.renderer.renderSession.roundPixels = true;

		spaceship = game.add.sprite(game.world.centerX, game.world.centerY, 'spaceship');			
		addFlyAnimation(spaceship);

		game.physics.arcade.enable(spaceship);
		game.camera.follow(spaceship);

		bullets = game.add.group();
    	bullets.enableBody = true;
    	bullets.physicsBodyType = Phaser.Physics.ARCADE;
    	bullets.createMultiple(5, 'green_bullet');
    
    	bullets.setAll('anchor.x', 0.5);
    	bullets.setAll('anchor.y', 0.5);
    	bullets.setAll('outOfBoundsKill', true);
    	bullets.setAll('checkWorldBounds', true);

		channel.on("update_state", update_state);
	}

	function addFlyAnimation(target) {
		target.anchor.setTo(0.5, 0.5);
		target.scale.setTo(0.6, 0.6);
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
	     if (game.input.activePointer.isDown) {        
        	fire();
		}

		if(timer % interval == 0) {
			timer = 0;
			channel.push("update_player", {
				id: current_id,
				x: spaceship.x,
				y: spaceship.y,
				r: spaceship.rotation
			});	
			var children = bullets.children;
			for(var i = 0; i < children.length; i++) {
				channel.push("fire_from_player", {
					id: current_id + i,
					x: children[i].x,
					y: children[i].y,
					player: current_id,
					r: children[i].rotation
				});	
			}
		} 

	    timer++;
	}

	function render() {
		//game.debug.spriteInfo(spaceship, 32, 100);
	}


	function fire () {
    	if (game.time.now > nextFire && bullets.countDead() > 0) {
        	nextFire = game.time.now + fireRate;

        	var bullet = bullets.getFirstExists(false);

        	bullet.reset(spaceship.x, spaceship.y);

        	bullet.rotation = game.physics.arcade.moveToPointer(bullet, 1000, game.input.activePointer, 500);
    	}
	}

	function makeid() {
		var text = "";
		var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

		for( var i=0; i < 5; i++ )
			text += possible.charAt(Math.floor(Math.random() * possible.length));

		return text;
	}

	remove_not_found();
}

export default game