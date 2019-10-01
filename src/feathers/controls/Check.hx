/*
	Feathers UI
	Copyright 2019 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.controls;

import feathers.themes.steel.components.SteelCheckStyles;

/**
	@since 1.0.0
**/
@:styleContext
class Check extends ToggleButton {
	public function new() {
		initializeCheckTheme();

		super();
	}

	private function initializeCheckTheme():Void {
		SteelCheckStyles.initialize();
	}
}
