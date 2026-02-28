using Godot;
using System.Collections.Generic;
using System.Linq;

/// Connect game with SelectionManager class
public partial class PlayerSelectionManager : Node2D
{
	private Player owner;
	private SelectionManager selection;

	private bool dragging;
	private Vector2 dragStart;
	private Vector2 dragEnd;

	/// OnLoad - set owner player instance
	public override void _Ready()
	{
		owner = GetParent<Player>();
	}

	/// Handle input - drag select box
	public override void _Input(InputEvent @event)
	{
		// Handle Left mouse button action
		if (@event is InputEventMouseButton mb &&
			mb.ButtonIndex == MouseButton.Left)
		{
			if (mb.Pressed)
			{
				// button pressed
				dragging = true;
				dragStart = GetGlobalMousePosition();
			}
			else
			{
				// button unpressed
				dragging = false;
				dragEnd = GetGlobalMousePosition();

				Rect2 rect = new Rect2(dragStart, dragEnd - dragStart).Abs();

				var units = GetUnitsInside(rect);
				bool shiftHeld = Input.IsKeyPressed(Key.Shift);

				// check for shift-select
				if (shiftHeld)
				{
					selection.Add(units);
				}
				else
				{
					selection.Select(units);
				}

				QueueRedraw();
			}
		}

		// redraw box on mouse movement
		if (@event is InputEventMouseMotion && dragging)
		{
			dragEnd = GetGlobalMousePosition();
			QueueRedraw();
		}
	}

	/// Draw the selection box
	public override void _Draw()
	{
		if (!dragging) return;

		Vector2 localStart = ToLocal(dragStart);
		Vector2 localEnd = ToLocal(dragEnd);

		Rect2 rect = new Rect2(localStart, localEnd - localStart).Abs();

		DrawRect(rect, new Color(0, 1, 0, 0.2f), true);
		DrawRect(rect, Colors.Green, false, 2);
	}
	
	/// Get students inside selection box
	private IEnumerable<Student> GetUnitsInside(Rect2 rect)
	{
		return GetTree()
			.GetNodesInGroup("selectable_units")
			.OfType<Student>()
			.Where(s => rect.HasPoint(s.GlobalPosition));
	}
}
