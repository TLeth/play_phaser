part of Phaser;
/**
 * @author       Richard Davey <rich@photonstorm.com>
 * @copyright    2014 Photon Storm Ltd.
 * @license      {@link https://github.com/photonstorm/phaser/blob/master/license.txt|MIT License}
 */

/**
 * A Rope is a Sprite that has a repeating texture. The texture can be scrolled and scaled and will automatically wrap on the edges as it does so.
 * Please note that Ropes, as with normal Sprites, have no input handler or physics bodies by default. Both need enabling.
 *
 * @class Phaser.Rope
 * @constructor
 * @param {Phaser.Game} game - A reference to the currently running game.
 * @param {number} x - The x coordinate (in world space) to position the Rope at.
 * @param {number} y - The y coordinate (in world space) to position the Rope at.
 * @param {number} width - The width of the Rope.
 * @param {number} height - The height of the Rope.
 * @param {string|Phaser.RenderTexture|Phaser.BitmapData|PIXI.Texture} key - This is the image or texture used by the Rope during rendering. It can be a string which is a reference to the Cache entry, or an instance of a RenderTexture or PIXI.Texture.
 * @param {string|number} frame - If this Rope is using part of a sprite sheet or texture atlas you can specify the exact frame to use by giving a string or numeric index.
 */
class Rope extends PIXI.Rope implements GameObject, AnimationInterface {
  List points;
  bool _hasUpdateAnimation;
  Function _updateAnimationCallback;

  Game game;
  String name;
  int type;
  num z;
  Events events;
  AnimationManager animations;
  num _frame;
  String _frameName;
  Point _scroll;
  InputHandler input;
  Point world;
  bool checkWorldBounds;

  var key;

  Point tilePosition;
  bool _outOfBoundsFired = false;
  Function _updateAnimation = null;
  List<GameObject> children = [];
  GameObject get parent => super.parent;
  Rectangle _bounds;
  CanvasPattern __tilePattern;
  bool _dirty;

  num get renderOrderID {
    return this._cache[3];
  }
  Rectangle _currentBounds;

  List _cache;
  Point anchor = new Point();
  Point cameraOffset;
  bool autoCull;
  bool alive;
  Point center;
  Body body;

  Rope(Game game, [num x = 0, num y = 0, key, frame, List points])
      : super(null, points) {

//  this.points = [];
    this.points = points;
    this._hasUpdateAnimation = false;
    this._updateAnimationCallback = null;
//  x = x || 0;
//  y = y || 0;
//  key = key || null;
//  frame = frame || null;

    /**
   * @property {Phaser.Game} game - A reference to the currently running Game.
   */
    this.game = game;

    /**
   * @property {string} name - The user defined name given to this Sprite.
   * @default
   */
    this.name = '';

    /**
   * @property {number} type - The const type of this object.
   * @readonly
   */
    this.type = ROPE;

    /**
   * @property {number} z - The z-depth value of this object within its Group (remember the World is a Group as well). No two objects in a Group can have the same z value.
   */
    this.z = 0;

    /**
   * @property {Phaser.Events} events - The Events you can subscribe to that are dispatched when certain things happen on this Sprite or its components.
   */
    this.events = new Events(this);

    /**
   * @property {Phaser.AnimationManager} animations - This manages animations of the sprite. You can modify animations through it (see Phaser.AnimationManager)
   */
    this.animations = new AnimationManager(this);

    /**
   *  @property {string|Phaser.RenderTexture|Phaser.BitmapData|PIXI.Texture} key - This is the image or texture used by the Sprite during rendering. It can be a string which is a reference to the Cache entry, or an instance of a RenderTexture, BitmapData or PIXI.Texture.
   */
    this.key = key;

    /**
   * @property {number} _frame - Internal cache var.
   * @private
   */
    this._frame = 0;

    /**
   * @property {string} _frameName - Internal cache var.
   * @private
   */
    this._frameName = '';

    /**
   * @property {Phaser.Point} _scroll - Internal cache var.
   * @private
   */
    this._scroll = new Point();

    //PIXI.Rope.call(this, key, this.points);

    this.position.set(x, y);

    /**
   * @property {Phaser.InputHandler|null} input - The Input Handler for this object. Needs to be enabled with image.inputEnabled = true before you can use it.
   */
    this.input = null;

    /**
   * @property {Phaser.Point} world - The world coordinates of this Sprite. This differs from the x/y coordinates which are relative to the Sprites container.
   */
    this.world = new Point(x, y);

    /**
   * Should this Sprite be automatically culled if out of range of the camera?
   * A culled sprite has its renderable property set to 'false'.
   * Be advised this is quite an expensive operation, as it has to calculate the bounds of the object every frame, so only enable it if you really need it.
   *
   * @property {boolean} autoCull - A flag indicating if the Sprite should be automatically camera culled or not.
   * @default
   */
    this.autoCull = false;

    /**
   * If true the Sprite checks if it is still within the world each frame, when it leaves the world it dispatches Sprite.events.onOutOfBounds
   * and optionally kills the sprite (if Sprite.outOfBoundsKill is true). By default this is disabled because the Sprite has to calculate its
   * bounds every frame to support it, and not all games need it. Enable it by setting the value to true.
   * @property {boolean} checkWorldBounds
   * @default
   */
    this.checkWorldBounds = false;

    /**
   * @property {Phaser.Point} cameraOffset - If this object is fixedToCamera then this stores the x/y offset that its drawn at, from the top-left of the camera view.
   */
    this.cameraOffset = new Point();

    /**
   * By default Sprites won't add themselves to any physics system and their physics body will be `null`.
   * To enable them for physics you need to call `game.physics.enable(sprite, system)` where `sprite` is this object
   * and `system` is the Physics system you want to use to manage this body. Once enabled you can access all physics related properties via `Sprite.body`.
   *
   * Important: Enabling a Sprite for P2 or Ninja physics will automatically set `Sprite.anchor` to 0.5 so the physics body is centered on the Sprite.
   * If you need a different result then adjust or re-create the Body shape offsets manually, and/or reset the anchor after enabling physics.
   *
   * @property {Phaser.Physics.Arcade.Body|Phaser.Physics.P2.Body|Phaser.Physics.Ninja.Body|null} body
   * @default
   */
    this.body = null;

    /**
   * A small internal cache:
   * 0 = previous position.x
   * 1 = previous position.y
   * 2 = previous rotation
   * 3 = renderID
   * 4 = fresh? (0 = no, 1 = yes)
   * 5 = outOfBoundsFired (0 = no, 1 = yes)
   * 6 = exists (0 = no, 1 = yes)
   * 7 = fixed to camera (0 = no, 1 = yes)
   * 8 = destroy phase? (0 = no, 1 = yes)
   * @property {Array} _cache
   * @private
   */
    this._cache = [0, 0, 0, 0, 1, 0, 1, 0, 0];
    this.loadTexture(key, frame);

  }

  GameObject bringToTop([GameObject child]) {
    if (child == null) {
      if (this.parent != null) {
        this.parent.bringToTop(this);
      }
      return this;
    } else {
      if (child.parent == this && this.children.indexOf(child) < this.children.length) {
        this.removeChild(child);
        this.addChild(child);
      }
      return this;
    }
  }

//Phaser.Rope.prototype = Object.create(PIXI.Rope.prototype);
//Phaser.Rope.prototype.constructor = Phaser.Rope;

/**
 * Automatically called by World.preUpdate.
 *
 * @method Phaser.Rope#preUpdate
 * @memberof Phaser.Rope
 */
  preUpdate() {
    if (this._cache[4] == 1 && this.exists) {
      this.world.setTo(this.parent.position.x + this.position.x, this.parent.position.y + this.position.y);
      this.worldTransform.tx = this.world.x.toDouble();
      this.worldTransform.ty = this.world.y.toDouble();
      this._cache[0] = this.world.x;
      this._cache[1] = this.world.y;
      this._cache[2] = this.rotation;

      if (this.body != null) {
        this.body.preUpdate();
      }

      this._cache[4] = 0;

      return false;
    }

    this._cache[0] = this.world.x;
    this._cache[1] = this.world.y;
    this._cache[2] = this.rotation;

    if (!this.exists || !this.parent.exists) {
      //  Reset the renderOrderID
      this._cache[3] = -1;
      return false;
    }

    //  Cache the bounds if we need it
    if (this.autoCull || this.checkWorldBounds) {
      this._bounds = this.getBounds().clone();
    }

    if (this.autoCull) {
      //  Won't get rendered but will still get its transform updated
      this.renderable = this.game.world.camera.screenView.intersects(this._bounds);
    }

    if (this.checkWorldBounds) {
      //  The Sprite is already out of the world bounds, so let's check to see if it has come back again
      if (this._cache[5] == 1 && this.game.world.bounds.intersects(this._bounds)) {
        this._cache[5] = 0;
        this.events.onEnterBounds.dispatch(this);
      } else if (this._cache[5] == 0 && !this.game.world.bounds.intersects(this._bounds)) {
//  The Sprite WAS in the screen, but has now left.
        this._cache[5] = 1;
        this.events.onOutOfBounds.dispatch(this);
      }
    }

    this.world.setTo(this.game.camera.x + this.worldTransform.tx, this.game.camera.y + this.worldTransform.ty);

    if (this.visible) {
      this._cache[3] = this.game.stage.currentRenderOrderID++;
    }

    this.animations.update();

    if (this._scroll.x != 0) {
      this.tilePosition.x += this._scroll.x * this.game.time.physicsElapsed;
    }

    if (this._scroll.y != 0) {
      this.tilePosition.y += this._scroll.y * this.game.time.physicsElapsed;
    }

    if (this.body != null) {
      this.body.preUpdate();
    }


    {
      var i = 0;
      var len = this.children.length;
//  Update any Children
      for ( ; i < len; i++) {
        this.children[i].preUpdate();
      }
    }

    return true;

  }

/**
 * Override and use this function in your own custom objects to handle any update requirements you may have.
 *
 * @method Phaser.Rope#update
 * @memberof Phaser.Rope
 */
  update() {
    if (this._hasUpdateAnimation) {
      this.updateAnimation();
    }

  }

/**
 * Internal function called by the World postUpdate cycle.
 *
 * @method Phaser.Rope#postUpdate
 * @memberof Phaser.Rope
 */
  postUpdate() {
    if (this.exists && this.body != null) {
      this.body.postUpdate();
    }

    //  Fixed to Camera?
    if (this._cache[7] == 1) {
      this.position.x = this.game.camera.view.x + this.cameraOffset.x;
      this.position.y = this.game.camera.view.y + this.cameraOffset.y;
    }


    {
      var i = 0;
      var len = this.children.length;
      //  Update any Children
      for ( ; i < len; i++) {
        this.children[i].postUpdate();
      }
    }
  }




/**
 * Changes the Texture the Rope is using entirely. The old texture is removed and the new one is referenced or fetched from the Cache.
 * This causes a WebGL texture update, so use sparingly or in low-intensity portions of your game.
 *
 * @method Phaser.Rope#loadTexture
 * @memberof Phaser.Rope
 * @param {string|Phaser.RenderTexture|Phaser.BitmapData|PIXI.Texture} key - This is the image or texture used by the Rope during rendering. It can be a string which is a reference to the Cache entry, or an instance of a RenderTexture, BitmapData or PIXI.Texture.
 * @param {string|number} frame - If this Rope is using part of a sprite sheet or texture atlas you can specify the exact frame to use by giving a string or numeric index.
 */
  loadTexture(key, [frame = 0]) {

    //frame = frame || 0;

    this.key = key;

    if (key is RenderTexture) {
      this.key = key.key;
      this.setTexture(key);
    } else if (key is BitmapData) {
      this.setTexture(key.texture);
    } else if (key is PIXI.Texture) {
      this.setTexture(key);
    } else {
      if (key == null) {
        this.key = '__default';
        this.setTexture(PIXI.TextureCache[this.key]);
      } else if (key is String && !this.game.cache.checkImageKey(key)) {
        window.console.warn("Texture with key '" + key + "' not found.");
        this.key = '__missing';
        this.setTexture(PIXI.TextureCache[this.key]);
      } else {
        this.setTexture(new PIXI.Texture(PIXI.BaseTextureCache[key]));
        this.animations.loadFrameData(this.game.cache.getFrameData(key), frame);
      }
    }

  }

/**
 * Sets the Texture frame the Rope uses for rendering.
 * This is primarily an internal method used by Rope.loadTexture, although you may call it directly.
 *
 * @method Phaser.Rope#setFrame
 * @memberof Phaser.Rope
 * @param {Phaser.Frame} frame - The Frame to be used by the Rope texture.
 */
  setFrame(frame) {

    this.texture.frame.x = frame.x;
    this.texture.frame.y = frame.y;
    this.texture.frame.width = frame.width;
    this.texture.frame.height = frame.height;

    this.texture.crop.x = frame.x;
    this.texture.crop.y = frame.y;
    this.texture.crop.width = frame.width;
    this.texture.crop.height = frame.height;

    if (frame.trimmed) {
      if (this.texture.trim != null) {
        this.texture.trim.x = frame.spriteSourceSizeX;
        this.texture.trim.y = frame.spriteSourceSizeY;
        this.texture.trim.width = frame.sourceSizeW;
        this.texture.trim.height = frame.sourceSizeH;
      } else {
        this.texture.trim = new Rectangle(frame.spriteSourceSizeX, frame.spriteSourceSizeY, frame.sourceSizeW, frame.sourceSizeH);
      }

      this.texture.width = frame.sourceSizeW;
      this.texture.height = frame.sourceSizeH;
      this.texture.frame.width = frame.sourceSizeW;
      this.texture.frame.height = frame.sourceSizeH;
    } else if (!frame.trimmed && this.texture.trim != null) {
      this.texture.trim = null;
    }

    if (this.game.renderType == WEBGL) {
      PIXI.WebGLRenderer.updateTextureFrame(this.texture);
    }

  }

/**
 * Destroys the Rope. This removes it from its parent group, destroys the event and animation handlers if present
 * and nulls its reference to game, freeing it up for garbage collection.
 *
 * @method Phaser.Rope#destroy
 * @memberof Phaser.Rope
 * @param {boolean} [destroyChildren=true] - Should every child of this object have its destroy method called?
 */
  destroy([bool destroyChildren = true]) {

    if (this.game == null || this.destroyPhase) {
      return;
    }

    //if ( destroyChildren == 'undefined') { destroyChildren = true; }

    this._cache[8] = 1;

    if (this.events != null) {
      this.events.onDestroy.dispatch(this);
    }

    if (this.filters != null) {
      this.filters = null;
    }

    if (this.parent != null) {
      if (this.parent is Group) {
        (this.parent as Group).remove(this);
      } else {
        (this.parent as Group).removeChild(this);
      }
    }

    this.animations.destroy();

    this.events.destroy();

    var i = this.children.length;

    if (destroyChildren) {
      while (i-- > 0) {
        this.children[i].destroy(destroyChildren);
      }
    } else {
      while (i-- > 0) {
        this.removeChild(this.children[i]);
      }
    }

    this.exists = false;
    this.visible = false;

    this.filters = null;
    this.mask = null;
    this.game = null;

    this._cache[8] = 0;

  }

/**
 * Play an animation based on the given key. The animation should previously have been added via sprite.animations.add()
 * If the requested animation is already playing this request will be ignored. If you need to reset an already running animation do so directly on the Animation object itself.
 *
 * @method Phaser.Rope#play
 * @memberof Phaser.Rope
 * @param {string} name - The name of the animation to be played, e.g. "fire", "walk", "jump".
 * @param {number} [frameRate=null] - The framerate to play the animation at. The speed is given in frames per second. If not provided the previously set frameRate of the Animation is used.
 * @param {boolean} [loop=false] - Should the animation be looped after playback. If not provided the previously set loop value of the Animation is used.
 * @param {boolean} [killOnComplete=false] - If set to true when the animation completes (only happens if loop=false) the parent Sprite will be killed.
 * @return {Phaser.Animation} A reference to playing Animation instance.
 */
  play(name, frameRate, loop, killOnComplete) {

    return this.animations.play(name, frameRate, loop, killOnComplete);

  }

/**
 * Resets the Rope. This places the Rope at the given x/y world coordinates, resets the tilePosition and then
 * sets alive, exists, visible and renderable all to true. Also resets the outOfBounds state.
 * If the Rope has a physics body that too is reset.
 *
 * @method Phaser.Rope#reset
 * @memberof Phaser.Rope
 * @param {number} x - The x coordinate (in world space) to position the Sprite at.
 * @param {number} y - The y coordinate (in world space) to position the Sprite at.
 * @return (Phaser.Rope) This instance.
 */
  reset(x, y) {

    this.world.setTo(x, y);
    this.position.x = x;
    this.position.y = y;
    this.alive = true;
    this.exists = true;
    this.visible = true;
    this.renderable = true;
    this._outOfBoundsFired = false;

    this.tilePosition.x = 0;
    this.tilePosition.y = 0;

    if (this.body != null) {
      this.body.reset(x, y, false, false);
    }

    this._cache[4] = 1;

    return this;

  }

/**
 * Indicates the rotation of the Sprite, in degrees, from its original orientation. Values from 0 to 180 represent clockwise rotation; values from 0 to -180 represent counterclockwise rotation.
 * Values outside this range are added to or subtracted from 360 to obtain a value within the range. For example, the statement player.angle = 450 is the same as player.angle = 90.
 * If you wish to work in radians instead of degrees use the property Sprite.rotation instead. Working in radians is also a little faster as it doesn't have to convert the angle.
 *
 * @name Phaser.Rope#angle
 * @property {number} angle - The angle of this Sprite in degrees.
 */
//Object.defineProperty(Phaser.Rope.prototype, "angle", {

  get angle {

    return Math.wrapAngle(Math.radToDeg(this.rotation));

  }

  set angle(value) {

    this.rotation = Math.degToRad(Math.wrapAngle(value));

  }

//});

/**
 * @name Phaser.Rope#frame
 * @property {number} frame - Gets or sets the current frame index and updates the Texture Cache for display.
 */
//Object.defineProperty(Phaser.Rope.prototype, "frame", {

  get frame {
    return this.animations.frame;
  }

  set frame(value) {

    if (value != this.animations.frame) {
      this.animations.frame = value;
    }

  }

//});

/**
 * @name Phaser.Rope#frameName
 * @property {string} frameName - Gets or sets the current frame name and updates the Texture Cache for display.
 */
//Object.defineProperty(Phaser.Rope.prototype, "frameName", {

  get frameName {
    return this.animations.frameName;
  }

  set frameName(value) {

    if (value != this.animations.frameName) {
      this.animations.frameName = value;
    }

  }

//});

/**
 * A Rope that is fixed to the camera uses its x/y coordinates as offsets from the top left of the camera. These are stored in Rope.cameraOffset.
 * Note that the cameraOffset values are in addition to any parent in the display list.
 * So if this Rope was in a Group that has x: 200, then this will be added to the cameraOffset.x
 *
 * @name Phaser.Rope#fixedToCamera
 * @property {boolean} fixedToCamera - Set to true to fix this Rope to the Camera at its current world coordinates.
 */
//Object.defineProperty(Phaser.Rope.prototype, "fixedToCamera", {

  get fixedToCamera {

    return this._cache[7] == 1;

  }

  set fixedToCamera(value) {

    if (value) {
      this._cache[7] = 1;
      this.cameraOffset.set(this.x, this.y);
    } else {
      this._cache[7] = 0;
    }
  }

//});

/**
 * Rope.exists controls if the core game loop and physics update this Rope or not.
 * When you set Rope.exists to false it will remove its Body from the physics world (if it has one) and also set Rope.visible to false.
 * Setting Rope.exists to true will re-add the Body to the physics world (if it has a body) and set Rope.visible to true.
 *
 * @name Phaser.Rope#exists
 * @property {boolean} exists - If the Rope is processed by the core game update and physics.
 */
//Object.defineProperty(Phaser.Rope.prototype, "exists", {

  get exists {

    return this._cache[6] == 1;

  }

  set exists(value) {

    if (value) {
//  exists = true
      this._cache[6] = 1;

      if (this.body != null && this.body.type == Physics.P2JS) {
        this.body.addToWorld();
      }

      this.visible = true;
    } else {
//  exists = false
      this._cache[6] = 0;

      if (this.body != null && this.body.type == Physics.P2JS) {
        this.body.safeRemove = true;
      }

      this.visible = false;

    }
  }

//});

/**
 * By default a Rope won't process any input events at all. By setting inputEnabled to true the Phaser.InputHandler is
 * activated for this object and it will then start to process click/touch events and more.
 *
 * @name Phaser.Rope#inputEnabled
 * @property {boolean} inputEnabled - Set to true to allow this object to receive input events.
 */
//Object.defineProperty(Phaser.Rope.prototype, "inputEnabled", {

  get inputEnabled {

    return (this.input != null && this.input.enabled);

  }

  set inputEnabled(value) {

    if (value) {
      if (this.input == null) {
        this.input = new InputHandler(this);
        this.input.start();
      } else if (this.input != null && !this.input.enabled) {
        this.input.start();
      }
    } else {
      if (this.input != null && this.input.enabled) {
        this.input.stop();
      }
    }

  }

//});

/**
 * The position of the Rope on the x axis relative to the local coordinates of the parent.
 *
 * @name Phaser.Rope#x
 * @property {number} x - The position of the Rope on the x axis relative to the local coordinates of the parent.
 */
//Object.defineProperty(Phaser.Rope.prototype, "x", {

  get x {

    return this.position.x;

  }

  set x(value) {

    this.position.x = value;

    if (this.body != null && this.body.type == Physics.ARCADE && this.body.phase == 2) {
      this.body._reset = true;
    }

  }

//});

/**
 * The position of the Rope on the y axis relative to the local coordinates of the parent.
 *
 * @name Phaser.Rope#y
 * @property {number} y - The position of the Rope on the y axis relative to the local coordinates of the parent.
 */
//Object.defineProperty(Phaser.Rope.prototype, "y", {

  get y {

    return this.position.y;

  }

  set y(value) {

    this.position.y = value;

    if (this.body != null && this.body.type == Physics.ARCADE && this.body.phase == 2) {
      this.body._reset = true;
    }

  }

//});

/**
 * A Rope will call it's updateAnimation function on each update loop if it has one
 *
 * @name Phaser.Rope#updateAnimation
 * @property {function} updateAnimation - Set to a function if you'd like the rope to animate during the update phase. Set to false or null to remove it.
 */
//Object.defineProperty(Phaser.Rope.prototype, "updateAnimation", {

  Function get updateAnimation {

    return this._updateAnimation;

  }

  set updateAnimation(Function value) {
    if (value != null && value is Function) {
      this._hasUpdateAnimation = true;
      this._updateAnimation = value;
    } else {
      this._hasUpdateAnimation = false;
      this._updateAnimation = null;
    }

  }

//});

/**
 * The segments that make up the rope body as an array of Phaser.Rectangles
 *
 * @name Phaser.Rope#segments
 * @property {array} updateAnimation - Returns an array of Phaser.Rectangles that represent the segments of the given rope
 */
//Object.defineProperty(Phaser.Rope.prototype, "segments", {
  List<Rectangle> get segments {
    var segments = [];
    var index;
    var rect;
    var height;
    var width;
    var y2;
    var x2;
    var y1;
    var x1;
    for (int i = 0; i < this.points.length; i++) {
      index = i * 4;
      if (index + 4 >= this.verticies.length) {
        break;
      }
      x1 = this.verticies[index];
      y1 = this.verticies[index + 1];
      x2 = this.verticies[index + 4];
      y2 = this.verticies[index + 3];
      width = Math.difference(x1, x2);
      height = Math.difference(y1, y2);
      x1 += this.world.x;
      y1 += this.world.y;
      rect = new Rectangle(x1, y1, width, height);
      segments.add(rect);
    }
    return segments;
  }
//});

/**
 * @name Phaser.Rope#destroyPhase
 * @property {boolean} destroyPhase - True if this object is currently being destroyed.
 */
//Object.defineProperty(Phaser.Rope.prototype, "destroyPhase", {

  get destroyPhase {

    return this._cache[8] == 1;

  }

//});
}
