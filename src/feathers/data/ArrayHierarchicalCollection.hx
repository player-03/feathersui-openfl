/*
	Feathers UI
	Copyright 2026 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

package feathers.data;

import feathers.events.FeathersEvent;
import feathers.events.HierarchicalCollectionEvent;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.utils.IDataInput;
import openfl.utils.IDataOutput;
import openfl.utils.IExternalizable;

/**
	Wraps an `Array` data source with a common API for use with UI controls that
	support hierarchical data, such as `TreeView` or `TreeGridView`.

	@event openfl.events.Event.CHANGE Dispatched when the collection changes.

	@event feathers.events.HierarchicalCollectionEvent.ADD_ITEM Dispatched when
	an item is added to the collection.

	@event feathers.events.HierarchicalCollectionEvent.REMOVE_ITEM Dispatched
	when an item is removed from the collection.

	@event feathers.events.HierarchicalCollectionEvent.REPLACE_ITEM Dispatched
	when an item is replaced in the collection.

	@event feathers.events.HierarchicalCollectionEvent.REMOVE_ALL Dispatched
	when all items are removed from the collection.

	@event feathers.events.HierarchicalCollectionEvent.RESET Dispatched
	when the source of the collection is changed.

	@event feathers.events.HierarchicalCollectionEvent.UPDATE_ITEM Dispatched
	when `IHierarchicalCollection.updateAt()` is called.

	@event feathers.events.HierarchicalCollectionEvent.UPDATE_ALL Dispatched
	when `IHierarchicalCollection.updateAll()` is called.

	@event feathers.events.HierarchicalCollectionEvent.FILTER_CHANGE Dispatched
	when `IHierarchicalCollection.filterFunction` is changed.

	@event feathers.events.HierarchicalCollectionEvent.SORT_CHANGE Dispatched
	when `IHierarchicalCollection.sortCompareFunction` is changed.

	@see `feathers.controls.TreeView`
	@see `feathers.controls.TreeGridView`

	@since 1.0.0
**/
@:event(openfl.events.Event.CHANGE)
@:event(feathers.events.HierarchicalCollectionEvent.ADD_ITEM)
@:event(feathers.events.HierarchicalCollectionEvent.REMOVE_ITEM)
@:event(feathers.events.HierarchicalCollectionEvent.REPLACE_ITEM)
@:event(feathers.events.HierarchicalCollectionEvent.REMOVE_ALL)
@:event(feathers.events.HierarchicalCollectionEvent.RESET)
@:event(feathers.events.HierarchicalCollectionEvent.UPDATE_ITEM)
@:event(feathers.events.HierarchicalCollectionEvent.UPDATE_ALL)
@:event(feathers.events.HierarchicalCollectionEvent.FILTER_CHANGE)
@:event(feathers.events.HierarchicalCollectionEvent.SORT_CHANGE)
@defaultXmlProperty("array")
class ArrayHierarchicalCollection<T> extends EventDispatcher implements IHierarchicalCollection<T> implements IExternalizable {
	/**
		Creates a new `ArrayHierarchicalCollection` object with the given arguments.

		@since 1.0.0
	**/
	public function new(?array:Array<T>, ?itemToChildren:(T) -> Array<T>) {
		super();
		if (array == null) {
			array = [];
		}
		this.array = array;
		this.itemToChildren = itemToChildren;
	}

	private var _array:Array<T> = null;

	/**
		The `Array<T>` data source for this collection.

		The following example replaces the data source with a new array:

		```haxe
		collection.array = [];
		```

		@since 1.0.0
	**/
	@:bindable("reset")
	public var array(get, set):Array<T>;

	private function get_array():Array<T> {
		return this._array;
	}

	private function set_array(value:Array<T>):Array<T> {
		if (this._array == value) {
			return this._array;
		}
		if (value == null) {
			value = [];
		}
		this._array = value;
		this._pendingRefresh = true;
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.RESET, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._array;
	}

	private var _itemToChildren:(T) -> Array<T>;

	/**
		A function that returns an item's children. If the item is not a branch,
		the function should return `null`. If the item is a branch, but it
		contains no children, the function should return an empty array.

		@since 1.0.0
	**/
	public var itemToChildren(get, set):(T) -> Array<T>;

	private function get_itemToChildren():(T) -> Array<T> {
		return this._itemToChildren;
	}

	private function set_itemToChildren(value:(T) -> Array<T>):(T) -> Array<T> {
		if (this._itemToChildren == value) {
			return this._itemToChildren;
		}
		this._itemToChildren = value;
		this._pendingRefresh = true;
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.RESET, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._itemToChildren;
	}

	private var _root:Branch<T> = null;

	private var _pendingRefresh:Bool = false;

	private var _filterFunction:(T) -> Bool = null;

	/**
		@see `feathers.data.IHierarchicalCollection.filterFunction`
	**/
	@:bindable("filterChange")
	public var filterFunction(get, set):(T) -> Bool;

	private function get_filterFunction():(T) -> Bool {
		return this._filterFunction;
	}

	private function set_filterFunction(value:(T) -> Bool):(T) -> Bool {
		if (this._filterFunction == value) {
			return this._filterFunction;
		}
		this._filterFunction = value;
		this._pendingRefresh = true;
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.FILTER_CHANGE, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._filterFunction;
	}

	private var _sortCompareFunction:(T, T) -> Int = null;

	/**
		@see `feathers.data.IHierarchicalCollection.sortCompareFunction`
	**/
	@:bindable("sortChange")
	public var sortCompareFunction(get, set):(T, T) -> Int;

	private function get_sortCompareFunction():(T, T) -> Int {
		return this._sortCompareFunction;
	}

	private function set_sortCompareFunction(value:(T, T) -> Int):(T, T) -> Int {
		if (this._sortCompareFunction == value) {
			return this._sortCompareFunction;
		}
		this._sortCompareFunction = value;
		this._pendingRefresh = true;
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.SORT_CHANGE, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return this._sortCompareFunction;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.getLength`
	**/
	@:bindable("change")
	public function getLength(?location:Array<Int>):Int {
		if (location != null && location.length > 0) {
			var branch = this.getBranchAt(location);
			return branch.length;
		} else {
			if (this._pendingRefresh) {
				this.refreshFilterAndSort();
			}
			return this._root.length;
		}
	}

	/**
		@see `feathers.data.IHierarchicalCollection.get`
	**/
	@:bindable("change")
	public function get(location:Array<Int>):T {
		var branch = this.getBranchContaining(location);
		return branch.get(location[location.length - 1]);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.set`
	**/
	public function set(location:Array<Int>, item:T):Void {
		var branch = this.getBranchContaining(location);
		var index = location[location.length - 1];
		if (index < 0) {
			throw new RangeError('Could not set item at location $location');
		}
		var removedItem:Null<T> = index < branch.length ? branch.get(index) : null;
		branch.set(index, item, this._itemToChildren);
		this.refreshFilterAndSort(branch);
		switch ([removedItem != null, branch.contains(item)]) {
			case [true, true]:
				HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REPLACE_ITEM, location, item, removedItem);
				FeathersEvent.dispatch(this, Event.CHANGE);
			case [false, true]:
				HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.ADD_ITEM, location, item);
				FeathersEvent.dispatch(this, Event.CHANGE);
			case [true, false]:
				HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ITEM, location, null, removedItem);
				FeathersEvent.dispatch(this, Event.CHANGE);
			case [false, false]:
				// displayed items did not change
		}
	}

	/**
		@see `feathers.data.IHierarchicalCollection.isBranch`
	**/
	public function isBranch(item:T):Bool {
		if (item == null || this._itemToChildren == null) {
			return false;
		}
		return this._itemToChildren(item) != null;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.locationOf`
	**/
	public function locationOf(item:T):Array<Int> {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		var result:Array<Int> = [];
		if (this._root.find(item, result)) {
			return result;
		}
		return null;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.locationOf`
	**/
	public function contains(item:T):Bool {
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		return this._root.contains(item);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.addAt`
	**/
	public function addAt(itemToAdd:T, location:Array<Int>):Void {
		var branch = this.getBranchContaining(location);
		var sourceIndex = branch.getSourceIndex(location[location.length - 1]);
		if (sourceIndex < 0 || sourceIndex > branch.items.length) {
			throw new RangeError('Item cannot be added at location: ${location}');
		}
		branch.items.insert(sourceIndex, itemToAdd);
		branch.children.insert(sourceIndex, null);
		branch.refreshChildren(this._itemToChildren);
		this.refreshFilterAndSort(branch);
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.ADD_ITEM, location, itemToAdd);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.removeAt`
	**/
	public function removeAt(location:Array<Int>):T {
		var branch = this.getBranchContaining(location);
		var sourceIndex = branch.getSourceIndex(location[location.length - 1]);
		if (sourceIndex < 0 || sourceIndex >= branch.items.length) {
			throw new RangeError('Item not found at location: ${location}');
		}
		var removedItem = branch.items[sourceIndex];
		branch.items.splice(sourceIndex, 1);
		branch.children.splice(sourceIndex, 1);
		this.refreshFilterAndSort(branch);
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ITEM, location, null, removedItem);
		FeathersEvent.dispatch(this, Event.CHANGE);
		return removedItem;
	}

	/**
		@see `feathers.data.IHierarchicalCollection.remove`
	**/
	public function remove(item:T):Void {
		var location = this.locationOf(item);
		if (location == null) {
			// nothing to remove
			return;
		}
		this.removeAt(location);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.removeAll`
	**/
	public function removeAll(?location:Array<Int>):Void {
		if (this._pendingRefresh || this._root == null) {
			this.refreshFilterAndSort();
		}
		var branch = location != null && location.length > 0 ? this.getBranchAt(location) : this._root;
		if (branch.items.length == 0) {
			return;
		}
		resizeArray(branch.items, 0);
		resizeArray(branch.children, 0);
		if (branch.displayOrder != null) {
			resizeArray(branch.displayOrder, 0);
		}
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.REMOVE_ALL, location);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.updateAt`
	**/
	public function updateAt(location:Array<Int>):Void {
		var branch = this.getBranchContaining(location);
		var index = location[location.length - 1];
		if (index < 0 || index >= branch.length) {
			throw new RangeError('Failed to update item at index ${index}. Expected a value between 0 and ${branch.length - 1} at location ${location.slice(0, location.length - 1)}.');
		}
		this.refreshFilterAndSort(branch);
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.UPDATE_ITEM, location);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.updateAll`
	**/
	public function updateAll():Void {
		if (this._filterFunction != null || this._sortCompareFunction != null) {
			this._pendingRefresh = true;
		}
		HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.UPDATE_ALL, null);
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	/**
		@see `feathers.data.IHierarchicalCollection.refresh`
	**/
	public function refresh():Void {
		if (this._filterFunction == null && this._sortCompareFunction == null) {
			return;
		}
		this._pendingRefresh = true;
		if (this._filterFunction != null) {
			HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.FILTER_CHANGE, null);
		}
		if (this._sortCompareFunction != null) {
			HierarchicalCollectionEvent.dispatch(this, HierarchicalCollectionEvent.SORT_CHANGE, null);
		}
		FeathersEvent.dispatch(this, Event.CHANGE);
	}

	@:dox(hide)
	public function readExternal(input:IDataInput):Void {
		this.array = Std.downcast(input.readObject(), Array);
	}

	@:dox(hide)
	public function writeExternal(output:IDataOutput):Void {
		output.writeObject(this.array);
	}

	private function refreshFilterAndSort(?branch:Branch<T>):Void {
		// refresh all by default, only clear _pendingRefresh if refreshing all
		if (branch == null || branch == this._root) {
			this._pendingRefresh = false;
			if (this._root == null) {
				this._root = new Branch(this._array, this._itemToChildren);
			}
			branch = this._root;
		}

		if (this._filterFunction != null || this._sortCompareFunction != null) {
			this.refreshFilterAndSortInternal(branch);
		} else {
			branch.removeDisplayOrder();
		}
	}

	private function refreshFilterAndSortInternal(branch:Branch<T>):Void {
		var items = branch.items;
		var displayOrder = branch.displayOrder;
		branch.displayOrder = null;
		if (displayOrder == null) {
			displayOrder = [];
		}
		if (this._filterFunction == null) {
			resizeArray(displayOrder, items.length);
			for (i in 0...items.length) {
				displayOrder[i] = i;
			}
		} else {
			var newLength:Int = 0;
			for (i in 0...items.length) {
				if (this._filterFunction(items[i])) {
					displayOrder[newLength] = i;
					newLength++;
				}
			}
			resizeArray(displayOrder, newLength);
		}
		if (this._sortCompareFunction != null) {
			function sortCompareFunction(a:Int, b:Int):Int {
				return this._sortCompareFunction(items[a], items[b]);
			}
			displayOrder.sort(sortCompareFunction);
		}
		branch.displayOrder = displayOrder;

		for (index in displayOrder) {
			if (branch.children[index] != null) {
				refreshFilterAndSortInternal(branch.children[index]);
			}
		}
	}

	/**
		Returns the branch at `location`, if it's a branch. Throws an error if
		it can't be found, meaning this never returns null. Refreshes filter and
		sort if necessary.
	**/
	private function getBranchAt(location:Array<Int>):Branch<T> {
		if (location == null) {
			throw new RangeError('Item not found at location: ${location}');
		}
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		var branch = this._root;
		for (i in 0...location.length) {
			branch = branch.getChildren(location[i]);
			if (branch == null) {
				throw new RangeError('Item not found at location: ${location.slice(0, i + 1)}');
			}
		}
		return branch;
	}

	/**
		Returns the branch containing the item at `location`, which is the
		parent of the branch returned by `getBranchAt(location)`. Throws an
		error if it can't be found, meaning this never returns null. Refreshes
		filter and sort if necessary.
	**/
	private function getBranchContaining(location:Array<Int>):Branch<T> {
		if (location == null || location.length == 0) {
			throw new RangeError('Item not found at location: ${location}');
		}
		if (this._pendingRefresh) {
			this.refreshFilterAndSort();
		}
		var branch = this._root;
		for (i in 0...location.length - 1) {
			branch = branch.getChildren(location[i]);
			if (branch == null) {
				throw new RangeError('Item not found at location: ${location.slice(0, i + 1)}');
			}
		}
		return branch;
	}

	private static inline function resizeArray<T>(array:Array<T>, length:Int):Void {
		#if (hl && haxe_ver < 4.3)
		if (length == 0) {
			array.splice(0, array.length);
		} else {
			array.resize(length);
		}
		#else
		array.resize(length);
		#end
	}
}

private class Branch<T> {
	/**
		Child branches, in the same order as `items`. If a child is not a
		branch, that entry will be null.
	**/
	public var children:Array<Branch<T>>;

	/**
		Indices in `items`, after filtering and sorting. For instance, if
		`items` is `["red", "green", "blue"]` and an alphabetical sort is used,
		this will be `[2, 1, 0]` because "blue" (`items[2]`) is first and "red"
		(`items[0]`) is last.

		If no filtering and sorting is applied, this will be null.
	**/
	public var displayOrder:Array<Int> = null;

	/**
		The items in this branch, before filtering and sorting.
	**/
	public var items:Array<T>;

	public var length(get, never):Int;

	private inline function get_length():Int {
		return displayOrder != null ? displayOrder.length : items.length;
	}

	public inline function new(items:Array<T>, itemToChildren:(T) -> Array<T>) {
		this.items = items;
		this.children = [];
		this.refreshChildren(itemToChildren);
	}

	public function contains(item:T):Bool {
		if (displayOrder != null) {
			for (index in displayOrder) {
				if (index < 0 || index >= this.items.length) {
					continue;
				}
				if (this.items[index] == item || this.children[index] != null
					&& this.children[index].contains(item)) {
					return true;
				}
			}
			return false;
		}
		if (this.items.contains(item)) {
			return true;
		}
		for (child in children) {
			if (child != null && child.contains(item)) {
				return true;
			}
		}
		return false;
	}

	public function find(item:T, result:Array<Int>):Bool {
		if (displayOrder != null) {
			for (displayIndex => index in displayOrder) {
				if (findAtIndex(item, index, displayIndex, result)) {
					return true;
				}
			}
		} else {
			for (index in 0...this.items.length) {
				if (findAtIndex(item, index, index, result)) {
					return true;
				}
			}
		}

		return false;
	}

	private function findAtIndex(item:T, sourceIndex:Int, displayIndex:Int, result:Array<Int>):Bool {
		if (sourceIndex < 0 || sourceIndex >= this.items.length) {
			return false;
		}

		if (this.items[sourceIndex] == item) {
			result.push(displayIndex);
			return true;
		}

		var child = this.children[sourceIndex];
		if (child != null) {
			var resultLength = result.length;
			result.push(displayIndex);
			if (child.find(item, result)) {
				return true;
			}
			result.pop();
		}

		return false;
	}

	public function get(index:Int):T {
		index = this.getSourceIndex(index);
		if (index >= 0 && index < this.items.length) {
			return this.items[index];
		} else {
			throw new RangeError('Index $index is out of range 0...${this.items.length}');
		}
	}

	public function getChildren(index:Int):Branch<T> {
		index = this.getSourceIndex(index);
		if (index >= 0 && index < this.children.length) {
			return this.children[index];
		} else {
			return null;
		}
	}

	public inline function getSourceIndex(index:Int):Int {
		if (this.displayOrder != null) {
			if (index >= 0 && index < this.displayOrder.length) {
				return this.displayOrder[index];
			} else {
				return -1;
			}
		} else {
			return index;
		}
	}

	public function set(index:Int, value:T, itemToChildren:(T) -> Array<T>):Void {
		var sourceIndex = this.getSourceIndex(index);
		if (sourceIndex >= 0 && sourceIndex <= this.items.length) {
			this.items[sourceIndex] = value;
			this.refreshChild(sourceIndex, value, itemToChildren);
		} else if (this.displayOrder != null && index == this.displayOrder.length) {
			this.items.push(value);
			this.refreshChild(this.items.length - 1, value, itemToChildren);
		} else {
			throw new RangeError('Index $sourceIndex is out of range 0...${this.items.length}');
		}
	}

	private inline function refreshChild(sourceIndex:Int, value:T, itemToChildren:(T) -> Array<T>):Void {
		var childItems = itemToChildren(value);
		if (childItems == null) {
			this.children[sourceIndex] = null;
		} else {
			var child = this.children[sourceIndex];
			if (child != null) {
				child.items = childItems;
			} else {
				this.children[sourceIndex] = child = new Branch(childItems, itemToChildren);
			}
			child.refreshChildren(itemToChildren);
		}
	}

	public function refreshChildren(itemToChildren:(T) -> Array<T>):Void {
		if (itemToChildren == null) {
			return;
		}
		if (this.children.length > this.items.length) {
			resizeArray(this.children, this.items.length);
		}
		for (i in 0...this.items.length) {
			refreshChild(i, this.items[i], itemToChildren);
		}
	}

	public function removeDisplayOrder():Void {
		this.displayOrder = null;
		for (child in this.children) {
			if (child != null) {
				child.removeDisplayOrder();
			}
		}
	}

	private static inline function resizeArray<T>(array:Array<T>, length:Int):Void {
		#if (hl && haxe_ver < 4.3)
		if (length == 0) {
			array.splice(0, array.length);
		} else {
			array.resize(length);
		}
		#else
		array.resize(length);
		#end
	}
}
