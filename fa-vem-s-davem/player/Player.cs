using Godot;

public partial class Player : RigidBody2D
{
	[Export] public float MaxSpeed = 300f;
	[Export] public float Acceleration = 500f;
	[Export] public float Friction = 400f;

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
		Vector2 inputDirection = Input.GetVector(
			"move_left",
			"move_right",
			"move_up",
            "move_down"
		);

		Vector2 targetVelocity = inputDirection * MaxSpeed;

		LinearVelocity = LinearVelocity.MoveToward(
			targetVelocity,
			Acceleration * (float)delta
		);
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
