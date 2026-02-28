using Godot;

public partial class Player : CharacterBody2D
{
	[Export] public float MaxSpeed = 300f;
	[Export] public float Acceleration = 800f;
	[Export] public float Friction = 600f;

	[Export] public float DeselectRing = 300f;
	[Export] public float CatchUpRing = 150f;
	[Export] public float StopRing = 100f;

	/// Selection handler for the player
	public SelectionManager Selection { get; private set; }

	/// OnEnterTree handler - create selection handler
	public override void _EnterTree()
	{
		Selection = new SelectionManager(this);
	}

	/// Movement handler
	public override void _PhysicsProcess(double delta)
	{
		// Get direction
		Vector2 inputDirection = Input.GetVector(
			"move_left",
			"move_right",
			"move_up",
            "move_down"
		);

		// Move according to direction
		if (inputDirection != Vector2.Zero)
		{
			Velocity = Velocity.MoveToward(
				inputDirection * MaxSpeed,
				Acceleration * (float)delta
			);
		}
		else
		{
			Velocity = Velocity.MoveToward(
				Vector2.Zero,
				Friction * (float)delta
			);
		}

		MoveAndSlide();
	}

	/// Draw player - currently draws selection rings around the player
	public override void _Draw()
	{
		Vector2 center = Vector2.Zero;

		DrawCircle(center, DeselectRing, Colors.DarkGray, false, 1f);
		DrawCircle(center, CatchUpRing, Colors.DarkGray, false, 1f);
		DrawCircle(center, StopRing, Colors.DarkGray, false, 1f);
	}
}
