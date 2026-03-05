using Godot;
using System;

/// Interface for selectable classes
public interface Selectable
{
	Player Player { get; set; }
	
	void Select(Player player);
	
	void Deselect();
}
