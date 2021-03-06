part of Phaser;



class TileSprite extends PIXI.TilingSprite implements GameObject, AnimationInterface {

  Game game;
  String name;
  num type;
  Events events;
  bool alive = true;

  GameObject get parent => super.parent;

  Body body;
  InputHandler input;
  AnimationManager animations;
  var key;

  num z;

  List<num> _cache;
  Rectangle _currentBounds;

  Point get center {
    return new Point(x + width / 2, y + height / 2);
  }

  var _frame;
  String _frameName;
  Point world;
  Point _scroll;
  bool _dirty = false;
  List<GameObject> children = [];
  Rectangle _bounds;

  bool checkWorldBounds;
  bool _outOfBoundsFired;

  bool autoCull;
  Point cameraOffset;

  CanvasPattern __tilePattern;


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


  num get renderOrderID {
    return this._cache[3];
  }

  /**
   * Indicates the rotation of the Sprite, in degrees, from its original orientation. Values from 0 to 180 represent clockwise rotation; values from 0 to -180 represent counterclockwise rotation.
   * Values outside this range are added to or subtracted from 360 to obtain a value within the range. For example, the statement player.angle = 450 is the same as player.angle = 90.
   * If you wish to work in radians instead of degrees use the property Sprite.rotation instead. Working in radians is also a little faster as it doesn't have to convert the angle.
   *
   * @name Phaser.TileSprite#angle
   * @property {number} angle - The angle of this Sprite in degrees.
   */
  //Object.defineProperty(Phaser.TileSprite.prototype, "angle", {

  get angle {

    return Math.wrapAngle(Math.radToDeg(this.rotation));

  }

  set angle(value) {

    this.rotation = Math.degToRad(Math.wrapAngle(value));

  }

  //});

  /**
   * @name Phaser.TileSprite#frame
   * @property {number} frame - Gets or sets the current frame index and updates the Texture Cache for display.
   */
  //Object.defineProperty(Phaser.TileSprite.prototype, "frame", {

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
   * @name Phaser.TileSprite#frameName
   * @property {string} frameName - Gets or sets the current frame name and updates the Texture Cache for display.
   */
  //Object.defineProperty(Phaser.TileSprite.prototype, "frameName", {

  String get frameName {
    return this.animations.frameName;
  }

  set frameName(String value) {

    if (value != this.animations.frameName) {
      this.animations.frameName = value;
    }

  }

  //});

  /**
   * An TileSprite that is fixed to the camera uses its x/y coordinates as offsets from the top left of the camera. These are stored in TileSprite.cameraOffset.
   * Note that the cameraOffset values are in addition to any parent in the display list.
   * So if this TileSprite was in a Group that has x: 200, then this will be added to the cameraOffset.x
   *
   * @name Phaser.TileSprite#fixedToCamera
   * @property {boolean} fixedToCamera - Set to true to fix this TileSprite to the Camera at its current world coordinates.
   */
  //Object.defineProperty(Phaser.TileSprite.prototype, "fixedToCamera", {

  bool get fixedToCamera {

    return this._cache[7] == 1;

  }

  set fixedToCamera(bool value) {

    if (value) {
      this._cache[7] = 1;
      this.cameraOffset.set(this.x, this.y);
    } else {
      this._cache[7] = 0;
    }
  }

  //});

  /**
   * TileSprite.exists controls if the core game loop and physics update this TileSprite or not.
   * When you set TileSprite.exists to false it will remove its Body from the physics world (if it has one) and also set TileSprite.visible to false.
   * Setting TileSprite.exists to true will re-add the Body to the physics world (if it has a body) and set TileSprite.visible to true.
   *
   * @name Phaser.TileSprite#exists
   * @property {boolean} exists - If the TileSprite is processed by the core game update and physics.
   */
  //Object.defineProperty(Phaser.TileSprite.prototype, "exists", {

  bool get exists {

    return this._cache[6] == 1;

  }

  set exists(bool value) {

    if (value) {
      //  exists = true
      this._cache[6] = 1;

      if (this.body != null && this.body.type == Physics.P2JS) {
        //TODO
        (this.body as P2.Body).addToWorld();
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
   * By default a TileSprite won't process any input events at all. By setting inputEnabled to true the Phaser.InputHandler is
   * activated for this object and it will then start to process click/touch events and more.
   *
   * @name Phaser.TileSprite#inputEnabled
   * @property {boolean} inputEnabled - Set to true to allow this object to receive input events.
   */
  //Object.defineProperty(Phaser.TileSprite.prototype, "inputEnabled", {

  bool get inputEnabled {

    return (this.input != null && this.input.enabled);

  }

  set inputEnabled(bool value) {

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
   * The position of the TileSprite on the x axis relative to the local coordinates of the parent.
   *
   * @name Phaser.TileSprite#x
   * @property {number} x - The position of the TileSprite on the x axis relative to the local coordinates of the parent.
   */
  //Object.defineProperty(Phaser.TileSprite.prototype, "x", {

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
   * The position of the TileSprite on the y axis relative to the local coordinates of the parent.
   *
   * @name Phaser.TileSprite#y
   * @property {number} y - The position of the TileSprite on the y axis relative to the local coordinates of the parent.
   */
  //Object.defineProperty(Phaser.TileSprite.prototype, "y", {

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
   * @name Phaser.TileSprite#destroyPhase
   * @property {boolean} destroyPhase - True if this object is currently being destroyed.
   */
  //Object.defineProperty(Phaser.TileSprite.prototype, "destroyPhase", {

  bool get destroyPhase {

    return this._cache[8] == 1;

  }

  //});


  TileSprite(this.game, [num x = 0, num y = 0, num width = 256, num height = 256, key, frame])
      : super(PIXI.TextureCache['__default'], width, height) {
    this.x = x.toInt();
    this.y = y.toInt();
    this.width = width.toInt();
    this.height = height.toInt();
//    this.key = key;
//    this.frame = frame;
    //x = x || 0;
    //y = y || 0;
    //width = width || 256;
    //height = height || 256;
    //key = key || null;
    //frame = frame || null;

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
    this.type = TILESPRITE;

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

    //PIXI.TilingSprite.call(this, PIXI.TextureCache['__default'], width, height);

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


  /**
   * Automatically called by World.preUpdate.
   *
   * @method Phaser.TileSprite#preUpdate
   * @memberof Phaser.TileSprite
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
      this._bounds.copyFrom(this.getBounds());
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
   * @method Phaser.TileSprite#update
   * @memberof Phaser.TileSprite
   */

  update() {

  }

  /**
   * Internal function called by the World postUpdate cycle.
   *
   * @method Phaser.TileSprite#postUpdate
   * @memberof Phaser.TileSprite
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
      int i = 0;
      int len = this.children.length;
      //  Update any Children
      for ( ; i < len; i++) {
        this.children[i].postUpdate();
      }
    }

  }

  /**
   * Sets this TileSprite to automatically scroll in the given direction until stopped via TileSprite.stopScroll().
   * The scroll speed is specified in pixels per second.
   * A negative x value will scroll to the left. A positive x value will scroll to the right.
   * A negative y value will scroll up. A positive y value will scroll down.
   *
   * @method Phaser.TileSprite#autoScroll
   * @memberof Phaser.TileSprite
   */

  autoScroll(num x, num y) {
    this._scroll.set(x, y);
  }

  /**
   * Stops an automatically scrolling TileSprite.
   *
   * @method Phaser.TileSprite#stopScroll
   * @memberof Phaser.TileSprite
   */

  stopScroll() {
    this._scroll.set(0, 0);
  }

  /**
   * Changes the Texture the TileSprite is using entirely. The old texture is removed and the new one is referenced or fetched from the Cache.
   * This causes a WebGL texture update, so use sparingly or in low-intensity portions of your game.
   *
   * @method Phaser.TileSprite#loadTexture
   * @memberof Phaser.TileSprite
   * @param {string|Phaser.RenderTexture|Phaser.BitmapData|PIXI.Texture} key - This is the image or texture used by the TileSprite during rendering. It can be a string which is a reference to the Cache entry, or an instance of a RenderTexture, BitmapData or PIXI.Texture.
   * @param {string|number} frame - If this TileSprite is using part of a sprite sheet or texture atlas you can specify the exact frame to use by giving a string or numeric index.
   */

  loadTexture(key, frame) {

    //frame = frame || 0;

    this.key = key;
    var setFrame = true;


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
        setFrame = !this.animations.loadFrameData(this.game.cache.getFrameData(key), frame);
      }
    }


    if (setFrame) {
      this._frame = new Rectangle().copyFrom(this.texture.frame);
    }


  }

  /**
   * Sets the Texture frame the TileSprite uses for rendering.
   * This is primarily an internal method used by TileSprite.loadTexture, although you may call it directly.
   *
   * @method Phaser.TileSprite#setFrame
   * @memberof Phaser.TileSprite
   * @param {Phaser.Frame} frame - The Frame to be used by the TileSprite texture.
   */

  setFrame(Frame frame) {

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
        this.texture.trim = new PIXI.Rectangle()
            ..x = frame.spriteSourceSizeX
            ..y = frame.spriteSourceSizeY
            ..width = frame.sourceSizeW
            ..height = frame.sourceSizeH;
        //};
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
   * Destroys the TileSprite. This removes it from its parent group, destroys the event and animation handlers if present
   * and nulls its reference to game, freeing it up for garbage collection.
   *
   * @method Phaser.TileSprite#destroy
   * @memberof Phaser.TileSprite
   * @param {boolean} [destroyChildren=true] - Should every child of this object have its destroy method called?
   */

  destroy([bool destroyChildren = true]) {

    if (this.game == null || this.destroyPhase) {
      return;
    }

    if (destroyChildren == null) {
      destroyChildren = true;
    }

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
        this.parent.removeChild(this);
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
    this.alive = false;

    this.filters = null;
    this.mask = null;
    this.game = null;

    this._cache[8] = 0;

  }

  /**
   * Play an animation based on the given key. The animation should previously have been added via sprite.animations.add()
   * If the requested animation is already playing this request will be ignored. If you need to reset an already running animation do so directly on the Animation object itself.
   *
   * @method Phaser.TileSprite#play
   * @memberof Phaser.TileSprite
   * @param {string} name - The name of the animation to be played, e.g. "fire", "walk", "jump".
   * @param {number} [frameRate=null] - The framerate to play the animation at. The speed is given in frames per second. If not provided the previously set frameRate of the Animation is used.
   * @param {boolean} [loop=false] - Should the animation be looped after playback. If not provided the previously set loop value of the Animation is used.
   * @param {boolean} [killOnComplete=false] - If set to true when the animation completes (only happens if loop=false) the parent Sprite will be killed.
   * @return {Phaser.Animation} A reference to playing Animation instance.
   */

  Animation play(String name, num frameRate, [bool loop, bool killOnComplete]) {

    return this.animations.play(name, frameRate, loop, killOnComplete);

  }

  /**
   * Resets the TileSprite. This places the TileSprite at the given x/y world coordinates, resets the tilePosition and then
   * sets alive, exists, visible and renderable all to true. Also resets the outOfBounds state.
   * If the TileSprite has a physics body that too is reset.
   *
   * @method Phaser.TileSprite#reset
   * @memberof Phaser.TileSprite
   * @param {number} x - The x coordinate (in world space) to position the Sprite at.
   * @param {number} y - The y coordinate (in world space) to position the Sprite at.
   * @return (Phaser.TileSprite) This instance.
   */

  reset(num x, num y) {

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

}
