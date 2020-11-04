package feathers.controls;

import feathers.controls.supportClasses.BaseDividedBox;
import feathers.core.IMeasureObject;
import feathers.core.IValidating;
import feathers.layout.VDividedBoxLayout;
import feathers.themes.steel.components.SteelVDividedBoxStyles;
import feathers.utils.DisplayUtil;
import openfl.display.DisplayObject;
#if (lime && !flash)
import lime.ui.MouseCursor as LimeMouseCursor;
#end

class VDividedBox extends BaseDividedBox {
	public function new() {
		this.initializeVDividedBoxTheme();

		super();

		#if (lime && !flash)
		this.resizeCursor = LimeMouseCursor.RESIZE_NS;
		#end
	}

	private var _vDividedBoxLayout:VDividedBoxLayout;
	private var _customItemHeights:Array<Null<Float>> = [];
	private var _fallbackFluidIndex:Int = -1;
	private var _resizeStartStageY:Float;
	private var _resizeStartHeight1:Float;
	private var _resizeStartHeight2:Float;

	override private function addItemAt(child:DisplayObject, index:Int):DisplayObject {
		var result = super.addItemAt(child, index);
		var explicitHeight:Null<Float> = null;
		if (Std.is(child, IMeasureObject)) {
			var measureChild = cast(child, IMeasureObject);
			explicitHeight = measureChild.explicitHeight;
		}
		this._customItemHeights.insert(index, explicitHeight);
		var layoutIndex = this._layoutItems.indexOf(child);
		if (explicitHeight == null) {
			if (this._fallbackFluidIndex == -1 || layoutIndex > this._fallbackFluidIndex) {
				this._fallbackFluidIndex = layoutIndex;
			}
		}
		return result;
	}

	override private function removeItem(child:DisplayObject):DisplayObject {
		var index = this.items.indexOf(child);
		var layoutIndex = this._layoutItems.indexOf(child);
		if (this._fallbackFluidIndex == layoutIndex) {
			this._fallbackFluidIndex = -1;
		}
		var result = super.removeItem(child);
		if (index != -1) {
			this._customItemHeights.splice(index, 1);
		}
		return result;
	}

	private function initializeVDividedBoxTheme():Void {
		SteelVDividedBoxStyles.initialize();
	}

	override private function initialize():Void {
		super.initialize();

		if (this._vDividedBoxLayout == null) {
			this._vDividedBoxLayout = new VDividedBoxLayout();
		}
		this._vDividedBoxLayout.customItemHeights = this._customItemHeights;
		this.layout = this._vDividedBoxLayout;
	}

	override private function handleLayout():Void {
		var oldIgnoreChildChanges = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		this._vDividedBoxLayout.fallbackFluidIndex = this._fallbackFluidIndex;
		this._ignoreChildChanges = oldIgnoreChildChanges;
		super.handleLayout();
	}

	override private function prepareResize(dividerIndex:Int, stageX:Float, stageY:Float):Void {
		this._resizeStartStageY = stageY;

		var firstItem = this.items[dividerIndex];
		var secondItem = this.items[dividerIndex + 1];
		this._resizeStartHeight1 = firstItem.height;
		this._resizeStartHeight2 = secondItem.height;

		if (this._currentResizeDraggingSkin != null) {
			var divider = this.dividers[dividerIndex];
			this._currentResizeDraggingSkin.x = divider.x;
			this._currentResizeDraggingSkin.width = divider.width;
			if (Std.is(this._currentResizeDraggingSkin, IValidating)) {
				cast(this._currentResizeDraggingSkin, IValidating).validateNow();
			}
			this._currentResizeDraggingSkin.y = divider.y + (divider.height - this._currentResizeDraggingSkin.height) / 2.0;
		}
	}

	override private function commitResize(dividerIndex:Int, stageX:Float, stageY:Float, live:Bool):Void {
		var offsetY = stageY - this._resizeStartStageY;
		offsetY *= DisplayUtil.getConcatenatedScaleY(this);

		if (live && !this.liveDragging) {
			if (this._currentResizeDraggingSkin != null) {
				var divider = this.dividers[dividerIndex];
				this._currentResizeDraggingSkin.x = divider.x;
				this._currentResizeDraggingSkin.width = divider.width;
				if (Std.is(this._currentResizeDraggingSkin, IValidating)) {
					cast(this._currentResizeDraggingSkin, IValidating).validateNow();
				}
				this._currentResizeDraggingSkin.y = divider.y + offsetY + (divider.height - this._currentResizeDraggingSkin.height) / 2.0;
			}
			return;
		}

		var totalHeight = this._resizeStartHeight1 + this._resizeStartHeight2;
		var firstItemHeight = this._resizeStartHeight1 + offsetY;
		if (firstItemHeight < 0.0) {
			firstItemHeight = 0.0;
		} else if (firstItemHeight > totalHeight) {
			firstItemHeight = totalHeight;
		}
		this._customItemHeights[dividerIndex] = firstItemHeight;
		this._customItemHeights[dividerIndex + 1] = totalHeight - firstItemHeight;
		this.setInvalid(LAYOUT);
	}
}
