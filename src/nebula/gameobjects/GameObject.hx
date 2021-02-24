package nebula.gameobjects;

import nebula.structs.TransformMatrix;
import nebula.math.RotateAround;
import nebula.math.MATH_CONST;
import nebula.assets.Texture;
import nebula.cameras.Camera;
import nebula.assets.Frame;
import nebula.scene.Scene;
import nebula.math.Angle;
import nebula.math.CMath;
import kha.math.Vector2;

/**
 * The base class that all Game Objects extend.
 * You don't create GameObjects directly and they cannot be added to the display list.
 * Instead, use them as the base for your own custom classes.
 */
class GameObject extends EventEmitter {
	/**
	 * The Scene to which this Game Object belongs.
	 * Game Objects can only belong to one Scene.
	 */
	public var scene:Scene;

	/**
	 * A textual representation of this Game Object, i.e. `sprite`.
	 * Used internally by Nebula but is available for your own custom classes to populate.
	 */
	public var type:String;

	/**
	 * The current state of this Game Object.
	 *
	 * Nebula itself will never modify this value, although plugins may do so.
	 *
	 * Use this property to track the state of a Game Object during its lifetime. For example, it could change from
	 * a state of 'moving', to 'attacking', to 'dead'. The state value should be an integer (ideally mapped to a constant
	 * in your game code), or a string. These are recommended to keep it light and simple, with fast comparisons.
	 * If you need to store complex data about your Game Object, look at using the Data Component instead.
	 */
	public var state:String = 'default';

	/**
	 * The name of this Game Object.
	 * Empty by default and never populated by Nebula, this is left for developers to use.
	 */
	public var name:String = '';

	/**
	 * The active state of this Game Object.
	 * A Game Object with an active state of `true` is processed by the Scenes UpdateList, if added to it.
	 * An active object is one which is having its logic and internal systems updated.
	 */
	public var active:Bool = true;

	/**
	 * A bitmask that controls if this Game Object is drawn by a Camera or not.
	 * Not usually set directly, instead call `Camera.ignore`, however you can
	 * set this property directly using the Camera.id property:
	 */
	public var cameraFilter:Int = 0;

	/**
	 * This Game Object will ignore all calls made to its destroy method if this flag is set to `true`.
	 * This includes calls that may come from a Group, Container or the Scene itself.
	 * While it allows you to persist a Game Object across Scenes, please understand you are entirely
	 * responsible for managing references to and from this Game Object.
	 */
	public var ignoreDestroy:Bool = false;

	/**
	 * The alpha value of the Game Object.
	 *
	 * This is a global value, impacting the entire Game Object, not just a region of it.
	 */
	public var alpha:Float = 1;

	/**
	 * Set the Alpha level of this Game Object. The alpha controls the opacity of the Game Object as it renders.
	 * Alpha values are provided as a float between 0, fully transparent, and 1, fully opaque.
	 *
	 * If your game is running under WebGL you can optionally specify four different alpha values, each of which
	 * correspond to the four corners of the Game Object. Under Canvas only the `topLeft` value given is used.
	 */
	public function setAlpha(value:Float = 1):Dynamic {
		
    alpha = value;

		return this;
	}

	/**
	 * Private internal value. Holds the depth of the Game Object.
	 */
	public var _depth:Int = 0;

	/**
	 * The depth of this Game Object within the Scene.
	 *
	 * The depth is also known as the 'z-index' in some environments, and allows you to change the rendering order
	 * of Game Objects, without actually moving their position in the display list.
	 *
	 * The default depth is zero. A Game Object with a higher depth
	 * value will always render in front of one with a lower value.
	 *
	 * Setting the depth will queue a depth sort event within the Scene.
	 */
	public var depth(get, set):Int;

	function get_depth():Int {
		return _depth;
	}

	function set_depth(value:Int):Int {
		scene.queueDepthSort();

		_depth = value;

		return _depth;
	}

	/**
	 * The depth of this Game Object within the Scene.
	 *
	 * The depth is also known as the 'z-index' in some environments, and allows you to change the rendering order
	 * of Game Objects, without actually moving their position in the display list.
	 *
	 * The default depth is zero. A Game Object with a higher depth
	 * value will always render in front of one with a lower value.
	 *
	 * Setting the depth will queue a depth sort event within the Scene.
	 */
	public function setDepth(value:Int = 0):Dynamic {
		depth = value;

		return this;
	}

	/**
	 * The horizontally flipped state of the Game Object.
	 *
	 * A Game Object that is flipped horizontally will render inversed on the horizontal axis.
	 * Flipping always takes place from the middle of the texture and does not impact the scale value.
	 * If this Game Object has a physics body, it will not change the body. This is a rendering toggle only.
	 */
	public var flipX:Bool = false;

	/**
	 * The vertically flipped state of the Game Object.
	 *
	 * A Game Object that is flipped vertically will render inversed on the vertical axis (i.e. upside down)
	 * Flipping always takes place from the middle of the texture and does not impact the scale value.
	 * If this Game Object has a physics body, it will not change the body. This is a rendering toggle only.
	 */
	public var flipY:Bool = false;

	/**
	 * Toggles the horizontal flipped state of this Game Object.
	 *
	 * A Game Object that is flipped horizontally will render inversed on the horizontal axis.
	 * Flipping always takes place from the middle of the texture and does not impact the scale value.
	 * If this Game Object has a physics body, it will not change the body. This is a rendering toggle only.
	 */
	public function toggleFlipX():Dynamic {
		flipX = !flipX;

		return this;
	}

	/**
	 * Toggles the vertical flipped state of this Game Object.
	 */
	public function toggleFlipY():Dynamic {
		flipY = !flipY;

		return this;
	}

	/**
	 * Sets the horizontal flipped state of this Game Object.
	 *
	 * A Game Object that is flipped horizontally will render inversed on the horizontal axis.
	 * Flipping always takes place from the middle of the texture and does not impact the scale value.
	 * If this Game Object has a physics body, it will not change the body. This is a rendering toggle only.
	 */
	public function setFlipX(value:Bool):Dynamic {
		flipX = value;

		return this;
	}

	/**
	 * Sets the vertical flipped state of this Game Object.
	 */
	public function setFlipY(value:Bool):Dynamic {
		flipY = value;

		return this;
	}

	/**
	 * Sets the horizontal and vertical flipped state of this Game Object.
	 *
	 * A Game Object that is flipped will render inversed on the flipped axis.
	 * Flipping always takes place from the middle of the texture and does not impact the scale value.
	 * If this Game Object has a physics body, it will not change the body. This is a rendering toggle only.
	 */
	public function setFlip(x:Bool, y:Bool):GameObject {
		flipX = x;
		flipY = y;

		return this;
	}

	/**
	 * Resets the horizontal and vertical flipped state of this Game Object back to their default un-flipped state.
	 */
	public function resetFlip():GameObject {
		flipX = false;
		flipY = false;

		return this;
	}

	/**
	 * Processes the bounds output vector before returning it.
	 */
	public function prepareBoundsOutput(output:Vector2, includeParent:Bool = false):Vector2 {
		if (rotation != 0) {
			RotateAround.rotateAround(output, x, y, rotation);
		}

		return output;
	}

	/**
	 * Gets the center coordinate of this Game Object, regardless of origin.
	 * The returned point is calculated in local space and does not factor in any parent containers
	 */
	public function getCenter(?output:Vector2, ?includeParent:Bool = false):Vector2 {
		if (output == null)
			output = new Vector2();

		output.x = x - (displayWidth * originX) + (displayWidth / 2);
		output.y = y - (displayHeight * originY) + (displayHeight / 2);

		return output;
	}

	/**
	 * Gets the top-left corner coordinate of this Game Object, regardless of origin.
	 * The returned point is calculated in local space and does not factor in any parent containers
	 */
	public function getTopLeft(?output:Vector2, includeParent:Bool = false):Vector2 {
		if (output == null)
			output = new Vector2(0, 0);

		output.x = x - (displayWidth * originX);
		output.y = y - (displayHeight * originY);

		return prepareBoundsOutput(output, includeParent);
	}

	/**
	 * Gets the top-center coordinate of this Game Object, regardless of origin.
	 * The returned point is calculated in local space and does not factor in any parent containers
	 */
	public function getTopCenter(?output:Vector2, includeParent:Bool = false):Vector2 {
		if (output == null)
			output = new Vector2(0, 0);

		output.x = (x - (displayWidth * originX)) + (displayWidth / 2);
		output.y = y - (displayHeight * originY);

		return prepareBoundsOutput(output, includeParent);
	}

	/**
	 * Gets the top-right corner coordinate of this Game Object, regardless of origin.
	 * The returned point is calculated in local space and does not factor in any parent containers
	 */
	public function getTopRight(?output:Vector2, includeParent:Bool = false):Vector2 {
		if (output == null)
			output = new Vector2(0, 0);

		output.x = (x - (displayWidth * originX)) + displayWidth;
		output.y = y - (displayHeight * originY);

		return prepareBoundsOutput(output, includeParent);
	}

	/**
	 * Gets the left-center coordinate of this Game Object, regardless of origin.
	 * The returned point is calculated in local space and does not factor in any parent containers
	 */
	public function getLeftCenter(?output:Vector2, includeParent:Bool = false):Vector2 {
		if (output == null)
			output = new Vector2(0, 0);

		output.x = x - (displayWidth * originX);
		output.y = (y - (displayHeight * originY)) + (displayHeight / 2);

    return prepareBoundsOutput(output, includeParent);
	}

	/**
	 * Gets the right-center coordinate of this Game Object, regardless of origin.
	 * The returned point is calculated in local space and does not factor in any parent containers
	 */
	public function getRightCenter(?output:Vector2, includeParent:Bool = false):Vector2 {
		if (output == null)
			output = new Vector2(0, 0);

		output.x = (x - (displayWidth * originX)) + displayWidth;
		output.y = (y - (displayHeight * originY)) + (displayHeight / 2);

    return prepareBoundsOutput(output, includeParent);
	}

	/**
	 * Gets the bottom-left corner coordinate of this Game Object, regardless of origin.
	 * The returned point is calculated in local space and does not factor in any parent containers
	 */
	public function getBottomLeft(?output:Vector2, includeParent:Bool = false):Vector2 {
		if (output == null)
			output = new Vector2(0, 0);

		output.x = x - (displayWidth * originX);
		output.y = (y - (displayHeight * originY)) + displayHeight;

    return prepareBoundsOutput(output, includeParent);
	}

	/**
	 * Gets the bottom-center coordinate of this Game Object, regardless of origin.
	 * The returned point is calculated in local space and does not factor in any parent containers
	 */
	public function getBottomCenter(?output:Vector2, includeParent:Bool = false):Vector2 {
		if (output == null)
			output = new Vector2(0, 0);

		output.x = (x - (displayWidth * originX)) + (displayWidth / 2);
		output.y = (y - (displayHeight * originY)) + displayHeight;

    return prepareBoundsOutput(output, includeParent);
	}

	/**
	 * Gets the bottom-right corner coordinate of this Game Object, regardless of origin.
	 * The returned point is calculated in local space and does not factor in any parent containers
	 */
	public function getBottomRight(?output:Vector2, includeParent:Bool = false):Vector2 {
		if (output == null)
			output = new Vector2(0, 0);

		output.x = (x - (displayWidth * originX)) + displayWidth;
		output.y = (y - (displayHeight * originY)) + displayHeight;

    return prepareBoundsOutput(output, includeParent);
	}

	/**
	 * The horizontal origin of this Game Object.
	 * The origin maps the relationship between the size and position of the Game Object.
	 * The default value is 0.5, meaning all Game Objects are positioned based on their center.
	 * Setting the value to 0 means the position now relates to the left of the Game Object.
	 */
	public var originX:Float = 0.5;

	/**
	 * The vertical origin of this Game Object.
	 * The origin maps the relationship between the size and position of the Game Object.
	 * The default value is 0.5, meaning all Game Objects are positioned based on their center.
	 * Setting the value to 0 means the position now relates to the top of the Game Object.
	 */
	public var originY:Float = 0.5;

	public var _displayOriginX:Float = 0;
	public var _displayOriginY:Float = 0;

	/**
	 * The horizontal display origin of this Game Object.
	 * The origin is a normalized value between 0 and 1.
	 * The displayOrigin is a pixel value, based on the size of the Game Object combined with the origin.
	 */
	public var displayOriginX(get, set):Float;

	function get_displayOriginX():Float {
		return _displayOriginX;
	}

	function set_displayOriginX(value):Float {
		_displayOriginX = value;
		originX = value / width;

		return value;
	}

	/**
	 * The vertical display origin of this Game Object.
	 * The origin is a normalized value between 0 and 1.
	 * The displayOrigin is a pixel value, based on the size of the Game Object combined with the origin.
	 */
	public var displayOriginY(get, set):Float;

	function get_displayOriginY():Float {
		return _displayOriginY;
	}

	function set_displayOriginY(value):Float {
		_displayOriginY = value;
		originY = value / height;

		return value;
	}

	/**
	 * Sets the origin of this Game Object.
	 *
	 * The values are given in the range 0 to 1.
	 */
	public function setOrigin(?x:Float = 0.5, ?y:Float = null):Dynamic {
		if (y == null) {
			y = x;
		}

		originX = x;
		originY = y;

		return updateDisplayOrigin();
	}

	/**
	 * Sets the origin of this Game Object based on the Pivot values in its Frame.
	 */
	// TODO: customPivot
	public function setOriginFromFrame():Dynamic {
		if (frame == null || !frame.customPivot) {
			return setOrigin();
		} else {
			originX = frame.pivotX;
			originY = frame.pivotY;
		}
		return updateDisplayOrigin();
	}

	/**
	 * Sets the display origin of this Game Object.
	 * The difference between this and setting the origin is that you can use pixel values for setting the display origin.
	 */
	public function setDisplayOrigin(?x:Float = 0, ?y:Float = null):Dynamic {
		if (y == null) {
			y = x;
		}

		displayOriginX = x;
		displayOriginY = y;

		return this;
	}

	/**
	 * Updates the Display Origin cached values internally stored on this Game Object.
	 * You don't usually call this directly, but it is exposed for edge-cases where you may.
	 */
	public function updateDisplayOrigin():Dynamic {
		_displayOriginX = originX * width;
		_displayOriginY = originY * height;

		return this;
	}

	/**
	 * The horizontal scroll factor of this Game Object.
	 *
	 * The scroll factor controls the influence of the movement of a Camera upon this Game Object.
	 *
	 * When a camera scrolls it will change the location at which this Game Object is rendered on-screen.
	 * It does not change the Game Objects actual position values.
	 *
	 * A value of 1 means it will move exactly in sync with a camera.
	 * A value of 0 means it will not move at all, even if the camera moves.
	 * Other values control the degree to which the camera movement is mapped to this Game Object.
	 *
	 * Please be aware that scroll factor values other than 1 are not taken in to consideration when
	 * calculating physics collisions. Bodies always collide based on their world position, but changing
	 * the scroll factor is a visual adjustment to where the textures are rendered, which can offset
	 * them from physics bodies if not accounted for in your code.
	 */
	public var scrollFactorX:Float = 1;

	/**
	 * The vertical scroll factor of this Game Object.
	 *
	 * The scroll factor controls the influence of the movement of a Camera upon this Game Object.
	 *
	 * When a camera scrolls it will change the location at which this Game Object is rendered on-screen.
	 * It does not change the Game Objects actual position values.
	 *
	 * A value of 1 means it will move exactly in sync with a camera.
	 * A value of 0 means it will not move at all, even if the camera moves.
	 * Other values control the degree to which the camera movement is mapped to this Game Object.
	 *
	 * Please be aware that scroll factor values other than 1 are not taken in to consideration when
	 * calculating physics collisions. Bodies always collide based on their world position, but changing
	 * the scroll factor is a visual adjustment to where the textures are rendered, which can offset
	 * them from physics bodies if not accounted for in your code.
	 */
	public var scrollFactorY:Float = 1;

	/**
	 * Sets the scroll factor of this Game Object.
	 *
	 * The scroll factor controls the influence of the movement of a Camera upon this Game Object.
	 *
	 * When a camera scrolls it will change the location at which this Game Object is rendered on-screen.
	 * It does not change the Game Objects actual position values.
	 *
	 * A value of 1 means it will move exactly in sync with a camera.
	 * A value of 0 means it will not move at all, even if the camera moves.
	 * Other values control the degree to which the camera movement is mapped to this Game Object.
	 *
	 * Please be aware that scroll factor values other than 1 are not taken in to consideration when
	 * calculating physics collisions. Bodies always collide based on their world position, but changing
	 * the scroll factor is a visual adjustment to where the textures are rendered, which can offset
	 * them from physics bodies if not accounted for in your code.
	 */
	function setScrollFactor(x:Float, ?y:Float = null):Dynamic {
		if (y == null) {
			y = x;
		}

		scrollFactorX = x;
		scrollFactorY = y;

		return this;
	}

	/**
	 * The native (un-scaled) width of this Game Object.
	 */
	public var width:Float = 0;

	/**
	 * The native (un-scaled) height of this Game Object.
	 *
	 * Changing this value will not change the size that the Game Object is rendered in-game.
	 * For that you need to either set the scale of the Game Object (`setScale`) or use
	 * the `displayHeight` property.
	 */
	public var height:Float = 0;

	/**
	 * The displayed width of this Game Object.
	 *
	 * This value takes into account the scale factor.
	 *
	 * Setting this value will adjust the Game Object's scale property.
	 */
	public var displayWidth(get, set):Float;

	function get_displayWidth():Float {
		return Math.abs(scaleX * frame.realWidth);
	}

	function set_displayWidth(value:Float):Float {
		scaleX = value / frame.realWidth;

		return Math.abs(scaleX * frame.realWidth);
	}

	/**
	 * The displayed height of this Game Object.
	 *
	 * This value takes into account the scale factor.
	 *
	 * Setting this value will adjust the Game Object's scale property.
	 */
	public var displayHeight(get, set):Float;

	function get_displayHeight():Float {
		return Math.abs(scaleY * frame.realHeight);
	}

	function set_displayHeight(value:Float):Float {
		scaleY = value / frame.realHeight;

		return Math.abs(scaleY * frame.realHeight);
	}

	/**
	 * Sets the size of this Game Object to be that of the given Frame.
	 *
	 * This will not change the size that the Game Object is rendered in-game.
	 * For that you need to either set the scale of the Game Object (`setScale`) or call the
	 * `setDisplaySize` method, which is the same thing as changing the scale but allows you
	 * to do so by giving pixel values.
	 *
	 * If you have enabled this Game Object for input, changing the size will _not_ change the
	 * size of the hit area. To do this you should adjust the `input.hitArea` object directly.
	 */
	public function setSizeToFrame(?_frame:Frame = null):Dynamic {
		if (_frame == null)
			_frame = frame;

		width = _frame.realWidth;
		height = _frame.realHeight;

		return this;
	}

	/**
	 * Sets the internal size of this Game Object, as used for frame or physics body creation.
	 *
	 * This will not change the size that the Game Object is rendered in-game.
	 * For that you need to either set the scale of the Game Object (`setScale`) or call the
	 * `setDisplaySize` method, which is the same thing as changing the scale but allows you
	 * to do so by giving pixel values.
	 *
	 * If you have enabled this Game Object for input, changing the size will _not_ change the
	 * size of the hit area. To do this you should adjust the `input.hitArea` object directly.
	 */
	public function setSize(w:Float, h:Float):Dynamic {
		width = w;
		height = h;

		return this;
	}

	/**
	 * Sets the display size of this Game Object.
	 *
	 * Calling this will adjust the scale.
	 */
	public function setDisplaySize(width:Float, height:Float):Dynamic {
		displayWidth = width;
		displayHeight = height;

		return this;
	}

	/**
	 * The Texture this Game Object is using to render with.
	 */
	// TODO: CanvasTexture
	public var texture:Texture = null;

	/**
	 * The Texture Frame this Game Object is using to render with.
	 */
	public var frame:Frame = null;

	/**
	 * A boolean flag indicating if this Game Object is being cropped or not.
	 * You can toggle this at any time after `setCrop` has been called, to turn cropping on or off.
	 * Equally, calling `setCrop` with no arguments will reset the crop and disable it.
	 */
	public var isCropped:Bool = false;

	/**
	 * The internal crop data object, as used by `setCrop` and passed to the `Frame.setCropUVs` method.
	 */ // To-Do Why Isn't this used by a Component?
	public var _crop:{
		u0:Float,
		v0:Float,
		u1:Float,
		v1:Float,
		x:Float,
		y:Float,
		cx:Float,
		cy:Float,
		cw:Float,
		ch:Float,
		width:Float,
		height:Float,
		flipX:Bool,
		flipY:Bool
	};

	/**
	 * Applies a crop to a texture based Game Object, such as a Sprite or Image.
	 *
	 * The crop is a rectangle that limits the area of the texture frame that is visible during rendering.
	 *
	 * Cropping a Game Object does not change its size, dimensions, physics body or hit area, it just
	 * changes what is shown when rendered.
	 *
	 * The crop coordinates are relative to the texture frame, not the Game Object, meaning 0 x 0 is the top-left.
	 *
	 * Therefore, if you had a Game Object that had an 800x600 sized texture, and you wanted to show only the left
	 * half of it, you could call `setCrop(0, 0, 400, 600)`.
	 *
	 * It is also scaled to match the Game Object scale automatically. Therefore a crop rect of 100x50 would crop
	 * an area of 200x100 when applied to a Game Object that had a scale factor of 2.
	 *
	 * You can either pass in numeric values directly, or you can provide a single Rectangle object as the first argument.
	 *
	 * Call this method with no arguments at all to reset the crop, or toggle the property `isCropped` to `false`.
	 *
	 * You should do this if the crop rectangle becomes the same size as the frame itself, as it will allow
	 * the renderer to skip several internal calculations.
	 */
	// TODO: Rectangle Version
	public function setCrop(?x:Float, ?y:Float, ?width:Float, ?height:Float):GameObject {
		if (x == null) {
			isCropped = false;
		} else if (frame != null) {
			frame.setCropUVs(_crop, x, y, width, height, flipX, flipY);
			isCropped = true;
		}

		return this;
	}

	/**
	 * Sets the texture and frame this Game Object will use to render with.
	 *
	 * Textures are referenced by their string-based keys, as stored in the Texture Manager.
	 */
	public function setTexture(key:String, frame:String):GameObject {
		texture = scene.assets.getTexture(key);
		return setFrame(frame);
	}

	/**
	 * Sets the frame this Game Object will use to render with.
	 *
	 * The Frame has to belong to the current Texture being used.
	 *
	 * It can be either a string or an index.
	 * Calling `setFrame` will modify the `width` and `height` properties of your Game Object.
	 * It will also change the `origin` if the Frame has a custom pivot point, as exported from packages like Texture Packer.
	 */
	public function setFrame(key:String, ?updateSize:Bool = true, ?updateOrigin:Bool = true):GameObject {
		frame = texture.get(key);

		if (updateSize)
			setSizeToFrame();

		if (updateOrigin) {
			if (frame.customPivot) {
				setOrigin(frame.pivotX, frame.pivotY);
			} else {
				updateDisplayOrigin();
			}
		}

		return this;
	}

	/**
	 * Internal method that returns a blank, well-formed crop object for use by a Game Object.
	 */
	private function resetCropObject():{
		u0:Float,
		v0:Float,
		u1:Float,
		v1:Float,
		x:Float,
		y:Float,
		cx:Float,
		cy:Float,
		cw:Float,
		ch:Float,
		width:Float,
		height:Float,
		flipX:Bool,
		flipY:Bool
	} {
		return {
			u0: 0,
			v0: 0,
			u1: 0,
			v1: 0,
			x: 0,
			y: 0,
			cx: 0,
			cy: 0,
			cw: 0,
			ch: 0,
			width: 0,
			height: 0,
			flipX: false,
			flipY: false
		};
	}

	/**
	 * Private internal value. Holds the horizontal scale value.
	 */
	public var _scaleX:Float = 1;

	/**
	 * Private internal value. Holds the vertical scale value.
	 */
	public var _scaleY:Float = 1;

	/**
	 * Private internal value. Holds the rotation value in radians.
	 */
	public var _rotation:Float = 0;

	/**
	 * The x position of this Game Object.
	 */
	public var x:Float = 0;

	/**
	 * The y position of this Game Object.
	 */
	public var y:Float = 0;

	/**
	 * This is a special setter that allows you to set both the horizontal and vertical scale of this Game Object
	 * to the same value, at the same time. When reading this value the result returned is `(scaleX + scaleY) / 2`.
	 */
	public var scale(get, set):Float;

	function get_scale():Float {
		return (_scaleX + _scaleY) / 2;
	}

	function set_scale(value:Float):Float {
		_scaleX = value;
		_scaleY = value;

		return get_scale();
	}

	/**
	 * This is a special setter that allows you to set both the horizontal and vertical scale of this Game Object
	 * to the same value, at the same time. When reading this value the result returned is `(scaleX + scaleY) / 2`.
	 *
	 * Use of this property implies you wish the horizontal and vertical scales to be equal to each other. If this
	 * isn't the case, use the `scaleX` or `scaleY` properties instead.
	 */
	public var scaleX(get, set):Float;

	function get_scaleX():Float {
		return _scaleX;
	}

	function set_scaleX(value:Float):Float {
		_scaleX = value;

		return get_scaleX();
	}

	/**
	 * The vertical scale of this Game Object.
	 */
	public var scaleY(get, set):Float;

	function get_scaleY():Float {
		return _scaleY;
	}

	function set_scaleY(value:Float):Float {
		_scaleY = value;

		return get_scaleY();
	}

	/**
	 * The angle of this Game Object in radians.
	 *
	 * Nebula uses a right-hand clockwise rotation system, where 0 is right, 90 is down, 180/-180 is left
	 * and -90 is up.
   */
	public var rotation(get, set):Float;

	function get_rotation():Float {
		return _rotation;
	}

	function set_rotation(value:Float):Float {
		//  value is in degrees
		_rotation = Angle.wrap(value);

		return get_rotation();
	}

	/**
	 * Sets the position of this Game Object.
	 */
	public function setPosition(?_x:Float = 0.0, ?_y:Float = null):Dynamic {
		if (_y == null) {
			_y = _x;
		}

		x = _x;
		y = _y;

		return this;
	}

	/**
	 * Sets the position of this Game Object to be a random position within the confines of
	 * the given area.
	 */
	public function setRandomPosition(?_x:Float = 0.0, ?_y:Float = 0.0, ?width:Float = null, ?height:Float = null):Dynamic {
		if (width == null) {
			width = scene.game.width;
		}
		if (height == null) {
			height = scene.game.height;
		}

		x = _x + (Math.random() * width);
		y = _y + (Math.random() * height);

		return this;
	}

	/**
	 * Sets the rotation of this Game Object.
	 */
	public function setRotation(?radians:Float = 0.0):Dynamic {
		rotation = radians;

		return this;
	}

	/**
	 * Sets the scale of this Game Object.
	 */
	public function setScale(?x:Float = 1.0, ?y:Float = null):Dynamic {
		if (y == null) {
			y = x;
		}

    scaleX = x;
    scaleY = y;

		return this;
	}

	/**
	 * Sets the x position of this Game Object.
	 */
	public function setX(?value:Float = 0.0):Dynamic {
		x = value;

		return this;
	}

	/**
	 * Sets the y position of this Game Object.
	 */
	public function setY(?value:Float = 0.0):Dynamic {
		y = value;

		return this;
	}

	/**
	 * Gets the local transform matrix for this Game Object.
	 */
  // TODO: what's this for?
	public function getLocalTransformMatrix(?tempMatrix:TransformMatrix = null):TransformMatrix {
		if (tempMatrix == null) {
			tempMatrix = new TransformMatrix();
		}

		return tempMatrix.applyITRS(x, y, _rotation, _scaleX, _scaleY);
	}

	/**
	 * Gets the world transform matrix for this Game Object, factoring in any parent Containers.
	 */
	public function getWorldTransformMatrix(?tempMatrix:TransformMatrix = null):TransformMatrix {
		if (tempMatrix == null) {
			tempMatrix = new TransformMatrix();
		}

		tempMatrix.applyITRS(x, y, _rotation, _scaleX, _scaleY);

		return tempMatrix;
	}

	/**
	 * The visible state of the Game Object.
	 *
	 * An invisible Game Object will skip rendering, but will still process update logic.
	 */
	private var visible:Bool = true;

	/**
	 * Sets the visibility of this Game Object.
	 *
	 * An invisible Game Object will skip rendering, but will still process update logic.
	 */
	public function setVisible(value:Bool):GameObject {
		visible = value;

		return this;
	}

	// INITIALIZE //
	public function new(_scene:Scene, _type:String) {
		super();

		scene = _scene;
		type = _type;

		// Tell the Scene to re-sort the children.
		scene.queueDepthSort();
	}

	/**
	 * Sets the `active` property of this Game Object and returns this Game Object for further chaining.
	 * A Game Object with its `active` property set to `true` will be updated by the Scenes UpdateList.
	 */
	public function setActive(value:Bool) {
		active = value;
		return this;
	}

	/**
	 * Sets the `name` property of this Game Object and returns this Game Object for further chaining.
	 * The `name` property is not populated by Phaser and is presented for your own use.
	 */
	public function setName(value:String) {
		name = value;
		return this;
	}

	/**
	 * Sets the current state of this Game Object.
	 *
	 * Phaser itself will never modify the State of a Game Object, although plugins may do so.
	 *
	 * For example, a Game Object could change from a state of 'moving', to 'attacking', to 'dead'.
	 * The state value should typically be an integer (ideally mapped to a constant
	 * in your game code), but could also be a string. It is recommended to keep it light and simple.
	 * If you need to store complex data about your Game Object, look at using the Data Component instead.
	 */
	public function setState(value:String) {
		state = value;
		return this;
	}

	/**
	 * This callback is invoked when this Game Object is added to a Scene.
	 *
	 * Can be overriden by custom Game Objects, but be aware of some Game Objects that
	 * will use this, such as Sprites, to add themselves into the Update List.
	 *
	 * You can also listen for the `ADDED_TO_SCENE` event from this Game Object.
	 */
	public function addedToScene() {}

	/**
	 * This callback is invoked when this Game Object is removed from a Scene.
	 *
	 * Can be overriden by custom Game Objects, but be aware of some Game Objects that
	 * will use this, such as Sprites, to removed themselves from the Update List.
	 *
	 * You can also listen for the `REMOVED_FROM_SCENE` event from this Game Object.
	 */
	public function removedFromScene() {}

	/**
	 * To be overridden by custom GameObjects. Allows base objects to be used in a Pool.
	 */
	public function preUpdate(time:Float, dela:Float) {}

	/**
	 * Compares the renderMask with the renderFlags to see if this Game Object will render or not.
	 * Also checks the Game Object against the given Cameras exclusion list.
	 */
	public function willRender(camera:Camera) {
    // TODO: not sure why we do a reverse reverse, will look into it.
		return !(!visible || alpha == 0 || (cameraFilter != 0 && (cameraFilter & camera.id) == 1));
	}

  // This is for GameObjects to override
	public function render(renderer:Renderer, camera:Camera) {}

	/**
	 * Returns an array containing the display list index of either this Game Object, or if it has one,
	 * its parent Container. It then iterates up through all of the parent containers until it hits the
	 * root of the display list (which is index 0 in the returned array).
	 *
	 * Used internally by the InputPlugin but also useful if you wish to find out the display depth of
	 * this Game Object and all of its ancestors.
	 */
	public function getIndexList() {
		var indexes = [];

		indexes.unshift(scene.displayList.getIndex(this));

		return indexes;
	}

	/**
	 * This method is called before the GameObject is destroyed
   * 
   * It is for personal use.
	 */
	public function preDestroy() {};

	/**
	 * Destroys this Game Object removing it from the Display List and Update List and
	 * severing all ties to parent resources.
	 *
	 * Also removes itself from the Input Manager and Physics Manager if previously enabled.
	 *
	 * Use this to remove a Game Object from your game if you don't ever plan to use it again.
	 * As long as no reference to it exists within your own code it should become free for
	 * garbage collection by the browser.
	 *
	 * If you just want to temporarily disable an object then look at using the
	 * Game Object Pool instead of destroying it, as destroyed objects cannot be resurrected.
	 */
	public function destroy(?fromScene:Bool = false) {
		// This Game Object has already been destroyed
		if (scene == null || ignoreDestroy) {
			return;
		}

		preDestroy();

		emit('DESTROY', this);

		if (!fromScene) {
			scene.displayList.remove([this]);
		}

		// Tell the Scene to re-sort the children
		if (!fromScene) {
			scene.queueDepthSort();
		}

		active = false;

		scene = null;

		removeAllListeners();
	}
}