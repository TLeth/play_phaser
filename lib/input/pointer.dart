part of Phaser;

class Pointer {
  Game game;
  int id;
  int type;
  bool exists;
  int identifier;
  int pointerId;
  var target;
  var button;

  bool _holdSent;
  List _history;

  double _nextDrop;
  bool _stateReset;
  bool withinGame;
  int clientX;
  int clientY;

  int pageX;
  int pageY;

  int screenX;
  int screenY;

  int rawMovementX;
  int rawMovementY;

  int movementX;
  int movementY;

  num x;
  num y;

  bool isMouse;
  bool isDown;
  bool isUp;
  bool isOver;
  bool isOut;

  num timeOver;
  num timeOut;
  num timeDown;
  num timeUp;

  num downDuration;

  bool isDragged;

  num previousTapTime;
  int totalTouches;

  //TODO
  num msSinceLastClick = 999999999.0;

  InputHandler targetObject;

  int _highestRenderOrderID;
  InputHandler _highestRenderObject;
  int _highestInputPriorityID;

  bool active;
  Point position;
  Point positionDown;
  Point positionUp;

  Circle circle;

  /**
      * @property {boolean} dirty - A dirty pointer needs to re-poll any interactive objects it may have been over, regardless if it has moved or not.
      * @default
      */
  bool dirty = false;

  num get duration {
    if (this.isUp) {
      return -1.0;
    }

    return this.game.time.now - this.timeDown;
  }

  num get worldX {
    return this.game.world.camera.x + this.x;
  }

  num get worldY {
    return this.game.world.camera.y + this.y;
  }


  Pointer(this.game, this.id) {
    /**
     * @property {Phaser.Game} game - A reference to the currently running game.
     */
    this.game = game;

    /**
     * @property {number} id - The ID of the Pointer object within the game. Each game can have up to 10 active pointers.
     */
    this.id = id;

    /**
     * @property {number} type - The const type of this object.
     * @readonly
     */
    this.type = POINTER;

    /**
     * @property {boolean} exists - A Pointer object that exists is allowed to be checked for physics collisions and overlaps.
     * @default
     */
    this.exists = true;

    /**
     * @property {number} identifier - The identifier property of the Pointer as set by the DOM event when this Pointer is started.
     * @default
     */
    this.identifier = 0;

    /**
     * @property {number} pointerId - The pointerId property of the Pointer as set by the DOM event when this Pointer is started. The browser can and will recycle this value.
     * @default
     */
    this.pointerId = null;

    /**
     * @property {any} target - The target property of the Pointer as set by the DOM event when this Pointer is started.
     * @default
     */
    this.target = null;

    /**
     * @property {any} button - The button property of the Pointer as set by the DOM event when this Pointer is started.
     * @default
     */
    this.button = null;

    /**
     * @property {boolean} _holdSent - Local private variable to store the status of dispatching a hold event.
     * @private
     * @default
     */
    this._holdSent = false;

    /**
     * @property {array} _history - Local private variable storing the short-term history of pointer movements.
     * @private
     */
    this._history = [];

    /**
     * @property {number} _nextDrop - Local private variable storing the time at which the next history drop should occur.
     * @private
     */
    this._nextDrop = 0.0;

    /**
     * @property {boolean} _stateReset - Monitor events outside of a state reset loop.
     * @private
     */
    this._stateReset = false;

    /**
     * @property {boolean} withinGame - true if the Pointer is over the game canvas, otherwise false.
     */
    this.withinGame = false;

    /**
     * @property {number} clientX - The horizontal coordinate of the Pointer within the application's client area at which the event occurred (as opposed to the coordinates within the page).
     */
    this.clientX = -1;

    /**
     * @property {number} clientY - The vertical coordinate of the Pointer within the application's client area at which the event occurred (as opposed to the coordinates within the page).
     */
    this.clientY = -1;

    /**
     * @property {number} pageX - The horizontal coordinate of the Pointer relative to whole document.
     */
    this.pageX = -1;

    /**
     * @property {number} pageY - The vertical coordinate of the Pointer relative to whole document.
     */
    this.pageY = -1;

    /**
     * @property {number} screenX - The horizontal coordinate of the Pointer relative to the screen.
     */
    this.screenX = -1;

    /**
     * @property {number} screenY - The vertical coordinate of the Pointer relative to the screen.
     */
    this.screenY = -1;

    /**
     * @property {number} rawMovementX - The horizontal raw relative movement of the Pointer in pixels since last event.
     * @default
     */
    this.rawMovementX = 0;

    /**
     * @property {number} rawMovementY - The vertical raw relative movement of the Pointer in pixels since last event.
     * @default
     */
    this.rawMovementY = 0;

    /**
     * @property {number} movementX - The horizontal processed relative movement of the Pointer in pixels since last event.
     * @default
     */
    this.movementX = 0;

    /**
     * @property {number} movementY - The vertical processed relative movement of the Pointer in pixels since last event.
     * @default
     */
    this.movementY = 0;

    /**
     * @property {number} x - The horizontal coordinate of the Pointer. This value is automatically scaled based on the game scale.
     * @default
     */
    this.x = -1;

    /**
     * @property {number} y - The vertical coordinate of the Pointer. This value is automatically scaled based on the game scale.
     * @default
     */
    this.y = -1;

    /**
     * @property {boolean} isMouse - If the Pointer is a mouse this is true, otherwise false.
     * @default
     */
    this.isMouse = false;

    /**
     * @property {boolean} isDown - If the Pointer is touching the touchscreen, or the mouse button is held down, isDown is set to true.
     * @default
     */
    this.isDown = false;

    /**
     * @property {boolean} isUp - If the Pointer is not touching the touchscreen, or the mouse button is up, isUp is set to true.
     * @default
     */
    this.isUp = true;

    /**
     * @property {number} timeDown - A timestamp representing when the Pointer first touched the touchscreen.
     * @default
     */
    this.timeDown = 0.0;

    /**
     * @property {number} timeUp - A timestamp representing when the Pointer left the touchscreen.
     * @default
     */
    this.timeUp = 0.0;

    /**
     * @property {number} previousTapTime - A timestamp representing when the Pointer was last tapped or clicked.
     * @default
     */
    this.previousTapTime = 0.0;

    /**
     * @property {number} totalTouches - The total number of times this Pointer has been touched to the touchscreen.
     * @default
     */
    this.totalTouches = 0;

    /**
     * @property {number} msSinceLastClick - The number of milliseconds since the last click or touch event.
     * @default
     */
    this.msSinceLastClick = 999999999.0;

    /**
     * @property {any} targetObject - The Game Object this Pointer is currently over / touching / dragging.
     * @default
     */
    this.targetObject = null;

    /**
     * @property {boolean} active - An active pointer is one that is currently pressed down on the display. A Mouse is always active.
     * @default
     */
    this.active = false;

    /**
     * @property {Phaser.Point} position - A Phaser.Point object containing the current x/y values of the pointer on the display.
     */
    this.position = new Point();

    /**
     * @property {Phaser.Point} positionDown - A Phaser.Point object containing the x/y values of the pointer when it was last in a down state on the display.
     */
    this.positionDown = new Point();

    /**
     * @property {Phaser.Point} positionUp - A Phaser.Point object containing the x/y values of the pointer when it was last released.
     */
    this.positionUp = new Point();

    /**
     * A Phaser.Circle that is centered on the x/y coordinates of this pointer, useful for hit detection.
     * The Circle size is 44px (Apples recommended "finger tip" size).
     * @property {Phaser.Circle} circle
     */
    this.circle = new Circle(0, 0, 44);

    if (id == 0) {
      this.isMouse = true;
    }
  }

  /**
   * Called when the Pointer is pressed onto the touchscreen.
   * @method Phaser.Pointer#start
   * @param {any} event - The DOM event from the browser.
   */

  start(event) {
    //    if (event is MouseEvent) {
    //      MouseEvent me = event as MouseEvent;
    //      //me.target
    //    }
    //    if (event['pointerId']) {
    //      this.pointerId = event.pointerId;
    //    }

    if (event is JsObject) {
      this.pointerId = event['pointerId'];
      this.identifier = event['identifier'];
      this.target = event['target'];
    } else if (event is MouseEvent) {
      this.target = event.target;
    } else {
      //this.pointerId = event.pointerId;
      this.identifier = event.identifier;
      this.target = event.target;
    }

    //this.identifier = event.identifier;


    if (event is MouseEvent && event.button != null) {
      this.button = event.button;
    }

    this._history = [];
    this.active = true;
    this.withinGame = true;
    this.isDown = true;
    this.isUp = false;
    this.dirty = false;

    //  Work out how long it has been since the last click
    this.msSinceLastClick = this.game.time.now - this.timeDown;
    this.timeDown = this.game.time.now;
    this._holdSent = false;

    //  This sets the x/y and other local values
    this.move(event, true);

    // x and y are the old values here?
    this.positionDown.setTo(this.x, this.y);

    if (this.game.input.multiInputOverride == Input.MOUSE_OVERRIDES_TOUCH || this.game.input.multiInputOverride == Input.MOUSE_TOUCH_COMBINE || (this.game.input.multiInputOverride == Input.TOUCH_OVERRIDES_MOUSE && this.game.input.currentPointers == 0)) {
      this.game.input.x = this.x;
      this.game.input.y = this.y;
      this.game.input.position.setTo(this.x, this.y);
      this.game.input.onDown.dispatch([this, event]);
      this.game.input.resetSpeed(this.x, this.y);
    }

    this._stateReset = false;
    this.totalTouches++;

    if (!this.isMouse) {
      this.game.input.currentPointers++;
    }

    if (this.targetObject != null) {
      this.targetObject._touchedHandler(this);
    }

    return this;

  }

  /**
   * Called by the Input Manager.
   * @method Phaser.Pointer#update
   */

  update() {

    if (this.active) {
      //  Force a check?
      if (this.dirty) {
        if (this.game.input.interactiveItems.length > 0) {
          this.processInteractiveObjects(true);
        }

        this.dirty = false;
      }

      if (this._holdSent == false && this.duration >= this.game.input.holdRate) {
        if (this.game.input.multiInputOverride == Input.MOUSE_OVERRIDES_TOUCH || this.game.input.multiInputOverride == Input.MOUSE_TOUCH_COMBINE || (this.game.input.multiInputOverride == Input.TOUCH_OVERRIDES_MOUSE && this.game.input.currentPointers == 0)) {
          this.game.input.onHold.dispatch(this);
        }

        this._holdSent = true;
      }

      //  Update the droppings history
      if (this.game.input.recordPointerHistory && this.game.time.now >= this._nextDrop) {
        this._nextDrop = this.game.time.now + this.game.input.recordRate;

        this._history.add({
          x: this.position.x,
          y: this.position.y
        });

        if (this._history.length > this.game.input.recordLimit) {
          this._history.removeAt(0);
        }
      }
    }

  }

  /**
   * Called when the Pointer is moved.
   * @method Phaser.Pointer#move
   * @param {MouseEvent|PointerEvent|TouchEvent} event - The event passed up from the input handler.
   * @param {boolean} [fromClick=false] - Was this called from the click event?
   */

  Pointer move(event, [bool fromClick = false]) {

    if (this.game.input.pollLocked) {
      return this;
    }

    //    if (fromClick == null) {
    //      fromClick = false;
    //    }

    if (event is MouseEvent && event.button != null) {
      this.button = event.button;
    }

    if (event is JsObject) {
      this.clientX = event['clientX'];
      this.clientY = event['clientY'];

      this.pageX = event['pageX'];
      this.pageY = event['pageY'];

      this.screenX = event['screenX'];
      this.screenY = event['screenY'];
    } else {

      this.clientX = event.client.x;
      this.clientY = event.client.y;

      this.pageX = event.page.x;
      this.pageY = event.page.y;

      this.screenX = event.screen.x;
      this.screenY = event.screen.y;
    }
    if (this.isMouse && this.game.input.mouse.locked && !fromClick) {
      this.rawMovementX = event.movement.x;
      this.rawMovementY = event.movement.y;

      this.movementX += this.rawMovementX;
      this.movementY += this.rawMovementY;
    }

    this.x = (this.pageX - this.game.scale.offset.x) * this.game.input.scale.x;
    this.y = (this.pageY - this.game.scale.offset.y) * this.game.input.scale.y;

    this.position.setTo(this.x, this.y);
    this.circle.x = this.x;
    this.circle.y = this.y;

    if (this.game.input.multiInputOverride == Input.MOUSE_OVERRIDES_TOUCH || this.game.input.multiInputOverride == Input.MOUSE_TOUCH_COMBINE || (this.game.input.multiInputOverride == Input.TOUCH_OVERRIDES_MOUSE && this.game.input.currentPointers == 0)) {
      this.game.input.activePointer = this;
      this.game.input.x = this.x;
      this.game.input.y = this.y;
      this.game.input.position.setTo(this.game.input.x, this.game.input.y);
      this.game.input.circle.x = this.game.input.x;
      this.game.input.circle.y = this.game.input.y;
    }

    this.withinGame = this.game.scale.bounds.contains(this.pageX, this.pageY);

    //  If the game is paused we don't process any target objects or callbacks
    if (this.game.paused) {
      return this;
    }


    int i = this.game.input.moveCallbacks.length;

    while (i-- > 0) {
      this.game.input.moveCallbacks[i]['callback'](this.x, this.y, fromClick);
    }

    //  Easy out if we're dragging something and it still exists
    if (this.targetObject != null && this.targetObject.isDragged == true) {
      if (this.targetObject.update(this) == false) {
        this.targetObject = null;
      }
    } else if (this.game.input.interactiveItems.length > 0) {
      this.processInteractiveObjects(fromClick);
    }

    return this;
//
//    //  Work out which object is on the top
//    this._highestRenderOrderID = 9999999999;
//    this._highestRenderObject = null;
//    this._highestInputPriorityID = -1;
//
//    //  Run through the list
//    if (this.game.input.interactiveItems.length > 0) {
//      for (InputHandler currentNode in this.game.input.interactiveItems) {
//        //var currentNode = this.game.input.interactiveItems.first;
//
//        //do {
//        //  If the object is using pixelPerfect checks, or has a higher InputManager.PriorityID OR if the priority ID is the same as the current highest AND it has a higher renderOrderID, then set it to the top
//        if (currentNode != null && currentNode.validForInput(this._highestInputPriorityID, this._highestRenderOrderID)) {
//
//          if ((!fromClick && currentNode.checkPointerOver(this)) || (fromClick && currentNode.checkPointerDown(this))) {
//            this._highestRenderOrderID = currentNode.sprite._cache[3]; // renderOrderID
//            this._highestInputPriorityID = currentNode.priorityID;
//            this._highestRenderObject = currentNode;
//          }
//        }
//        //currentNode = this.game.input.interactiveItems.next;
//      }
//      //while (currentNode != null);
//    }
//
//    if (this._highestRenderObject == null) {
//      //  The pointer isn't currently over anything, check if we've got a lingering previous target
//      if (this.targetObject != null) {
//        this.targetObject._pointerOutHandler(this);
//        this.targetObject = null;
//      }
//    } else {
//      if (this.targetObject == null) {
//        //  And now set the new one
//        this.targetObject = this._highestRenderObject;
//        this._highestRenderObject._pointerOverHandler(this);
//      } else {
//        //  We've got a target from the last update
//        if (this.targetObject == this._highestRenderObject) {
//          //  Same target as before, so update it
//          if (this._highestRenderObject.update(this) == false) {
//            this.targetObject = null;
//          }
//        } else {
//          //  The target has changed, so tell the old one we've left it
//          this.targetObject._pointerOutHandler(this);
//
//          //  And now set the new one
//          this.targetObject = this._highestRenderObject;
//          this.targetObject._pointerOverHandler(this);
//        }
//      }
//    }
//
//    return this;

  }

  /**
      * Process all interactive objects to find out which ones were updated in the recent Pointer move.
      * 
      * @method Phaser.Pointer#processInteractiveObjects
      * @protected
      * @param {boolean} [fromClick=false] - Was this called from the click event?
      * @return {boolean} True if this method processes an object (i.e. a Sprite becomes the Pointers currentTarget), otherwise false.
      */
  bool processInteractiveObjects([bool fromClick = false]) {

    this.game.input.interactiveItems.forEach((InputHandler i) {
      i.checked = false;
    });

    //  Work out which object is on the top
    this._highestRenderOrderID = double.MAX_FINITE.toInt();
    this._highestRenderObject = null;
    this._highestInputPriorityID = -1;

    //  First pass gets all objects that the pointer is over that DON'T use pixelPerfect checks and get the highest ID
    //  We know they'll be valid for input detection but not which is the top just yet

    //InputHandler currentNode = this.game.input.interactiveItems.first;
    this.game.input.interactiveItems.forEach((InputHandler currentNode) {
      if (currentNode != null && currentNode.validForInput(this._highestInputPriorityID, this._highestRenderOrderID, false)) {
        //  Flag it as checked so we don't re-scan it on the next phase
        currentNode.checked = true;

        if ((fromClick && currentNode.checkPointerDown(this, true)) || (!fromClick && currentNode.checkPointerOver(this, true))) {
          this._highestRenderOrderID = currentNode.sprite._cache[3]; // renderOrderID
          this._highestInputPriorityID = currentNode.priorityID;
          this._highestRenderObject = currentNode;
        }
      }
    });


    //  Then in the second sweep we process ONLY the pixel perfect ones that are checked and who have a higher ID
    //  because if their ID is lower anyway then we can just automatically discount them

    //currentNode = this.game.input.interactiveItems.first;

    this.game.input.interactiveItems.forEach((InputHandler currentNode) {
      if (currentNode != null && !currentNode.checked && currentNode.validForInput(this._highestInputPriorityID, this._highestRenderOrderID, true)) {
        if ((fromClick && currentNode.checkPointerDown(this, false)) || (!fromClick && currentNode.checkPointerOver(this, false))) {
          this._highestRenderOrderID = currentNode.sprite._cache[3]; // renderOrderID
          this._highestInputPriorityID = currentNode.priorityID;
          this._highestRenderObject = currentNode;
        }
      }
    });

    //  Now we know the top-most item (if any) we can process it
    if (this._highestRenderObject == null) {
      //  The pointer isn't currently over anything, check if we've got a lingering previous target
      if (this.targetObject != null) {
        this.targetObject._pointerOutHandler(this);
        this.targetObject = null;
      }
    } else {
      if (this.targetObject == null) {
        //  And now set the new one
        this.targetObject = this._highestRenderObject;
        this._highestRenderObject._pointerOverHandler(this);
      } else {
        //  We've got a target from the last update
        if (this.targetObject == this._highestRenderObject) {
          //  Same target as before, so update it
          if (this._highestRenderObject.update(this) == false) {
            this.targetObject = null;
          }
        } else {
          //  The target has changed, so tell the old one we've left it
          this.targetObject._pointerOutHandler(this);

          //  And now set the new one
          this.targetObject = this._highestRenderObject;
          this.targetObject._pointerOverHandler(this);
        }
      }
    }

    return (this.targetObject != null);

  }

  /**
   * Called when the Pointer leaves the target area.
   *
   * @method Phaser.Pointer#leave
   * @param {MouseEvent|PointerEvent|TouchEvent} event - The event passed up from the input handler.
   */

  leave(event) {

    this.withinGame = false;
    this.move(event, false);

  }

  /**
   * Called when the Pointer leaves the touchscreen.
   *
   * @method Phaser.Pointer#stop
   * @param {MouseEvent|PointerEvent|TouchEvent} event - The event passed up from the input handler.
   */

  Pointer stop(event) {

    if (this._stateReset) {
      event.preventDefault();
      return this;
    }

    this.timeUp = this.game.time.now;

    if (this.game.input.multiInputOverride == Input.MOUSE_OVERRIDES_TOUCH || this.game.input.multiInputOverride == Input.MOUSE_TOUCH_COMBINE || (this.game.input.multiInputOverride == Input.TOUCH_OVERRIDES_MOUSE && this.game.input.currentPointers == 0)) {
      this.game.input.onUp.dispatch([this, event]);

      //  Was it a tap?
      if (this.duration >= 0 && this.duration <= this.game.input.tapRate) {
        //  Was it a double-tap?
        if (this.timeUp - this.previousTapTime < this.game.input.doubleTapRate) {
          //  Yes, let's dispatch the signal then with the 2nd parameter set to true
          this.game.input.onTap.dispatch([this, true]);
        } else {
          //  Wasn't a double-tap, so dispatch a single tap signal
          this.game.input.onTap.dispatch([this, false]);
        }

        this.previousTapTime = this.timeUp;
      }
    }

    //  Mouse is always active
    if (this.id > 0) {
      this.active = false;
    }

    this.withinGame = false;
    this.isDown = false;
    this.isUp = true;
    this.pointerId = null;
    this.identifier = null;

    this.positionUp.setTo(this.x, this.y);

    if (this.isMouse == false) {
      this.game.input.currentPointers--;
    }

    int i = game.input.interactiveItems.length;
    while (i-- > 0) {
      game.input.interactiveItems[i]._releasedHandler(this);
    }
    //this.game.input.interactiveItems.forEach((InputHandler e) {
    //  e._releasedHandler(this);
    //});

    this.targetObject = null;

    return this;

  }

  /**
   * The Pointer is considered justPressed if the time it was pressed onto the touchscreen or clicked is less than justPressedRate.
   * Note that calling justPressed doesn't reset the pressed status of the Pointer, it will return `true` for as long as the duration is valid.
   * If you wish to check if the Pointer was pressed down just once then see the Sprite.events.onInputDown event.
   * @method Phaser.Pointer#justPressed
   * @param {number} [duration] - The time to check against. If none given it will use InputManager.justPressedRate.
   * @return {boolean} true if the Pointer was pressed down within the duration given.
   */

  bool justPressed([int duration]) {
    if (duration == null) {
      duration = this.game.input.justPressedRate;
    }
    return ((this.isDown == true) && (this.timeDown + duration) > this.game.time.now);
  }

  /**
   * The Pointer is considered justReleased if the time it left the touchscreen is less than justReleasedRate.
   * Note that calling justReleased doesn't reset the pressed status of the Pointer, it will return `true` for as long as the duration is valid.
   * If you wish to check if the Pointer was released just once then see the Sprite.events.onInputUp event.
   * @method Phaser.Pointer#justReleased
   * @param {number} [duration] - The time to check against. If none given it will use InputManager.justReleasedRate.
   * @return {boolean} true if the Pointer was released within the duration given.
   */

  bool justReleased([int duration]) {
    if (duration == null) {
      duration = this.game.input.justPressedRate;
    }
    return (this.isUp == true && (this.timeUp + duration) > this.game.time.now);

  }

  /**
   * Resets the Pointer properties. Called by InputManager.reset when you perform a State change.
   * @method Phaser.Pointer#reset
   */

  reset() {

    if (this.isMouse == false) {
      this.active = false;
    }

    this.pointerId = null;
    this.identifier = null;
    this.dirty = false;
    this.isDown = false;
    this.isUp = true;
    this.totalTouches = 0;
    this._holdSent = false;
    this._history.length = 0;
    this._stateReset = true;

    if (this.targetObject != null) {
      this.targetObject._releasedHandler(this);
    }

    this.targetObject = null;

  }

  /**
   * Resets the movementX and movementY properties. Use in your update handler after retrieving the values.
   * @method Phaser.Pointer#resetMovement
   */

  resetMovement() {

    this.movementX = 0;
    this.movementY = 0;

  }

}
