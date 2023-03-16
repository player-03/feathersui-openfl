/*
	Feathers UI
	Copyright 2023 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.skins;

import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;

/**
	A skin for Feathers UI components that draws a border at the top and bottom,
	but not the sides.

	@since 1.0.0
**/
class TopAndBottomBorderSkin extends BaseGraphicsPathSkin {
	/**
		Creates a new `TopAndBottomBorderSkin` object.

		@since 1.0.0
	**/
	public function new(?fill:FillStyle, ?border:LineStyle) {
		super(fill, border);
	}

	override private function draw():Void {
		var currentBorder = this.getCurrentBorder();
		var thickness = getLineThickness(currentBorder);
		var thicknessOffset = thickness / 2.0;

		var currentFill = this.getCurrentFill();
		if (currentFill != null) {
			this.applyFillStyle(currentFill);
			this.graphics.drawRect(0.0, thicknessOffset, this.actualWidth, Math.max(0.0, this.actualHeight - thickness));
			this.graphics.endFill();
		}

		var minLineX = Math.min(this.actualWidth, thicknessOffset);
		var minLineY = Math.min(this.actualHeight, thicknessOffset);
		var maxLineX = Math.max(minLineX, this.actualWidth - thicknessOffset);
		var maxLineY = Math.max(minLineY, this.actualHeight - thicknessOffset);

		this.applyLineStyle(currentBorder);
		// overline
		this.graphics.moveTo(minLineX, minLineY);
		this.graphics.lineTo(maxLineX, minLineY);
		// underline
		this.graphics.moveTo(minLineX, maxLineY);
		this.graphics.lineTo(maxLineX, maxLineY);
	}
}
