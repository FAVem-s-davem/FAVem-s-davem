using Godot;
using System;

public partial class Student : RigidBody2D, Selectable
{
	[Export] public float MaxSpeed = 200f;
	[Export] public float Acceleration = 1000f;
	[Export] public float Friction = 200f;

	public Player Player { get; set; }

	/// Mark student as selectable
	public override void _Ready()
	{
		AddToGroup("selectable_units");
	}

	/// Handle movement according to player position
	public override void _PhysicsProcess(double delta)
	{
		Vector2 inputDirection = Vector2.Zero;

		if (this.Player != null)
		{
			Vector2 toPlayer = this.Player.GlobalPosition - this.GlobalPosition;
			float dist = toPlayer.Length();

			if (dist > this.Player.DeselectRing)
			{
				Deselect();
			}
			else if (dist > this.Player.StopRing)
			{
				inputDirection = toPlayer.Normalized();

				if (dist > this.Player.CatchUpRing)
					inputDirection *= 1.5f;
			}
			else if (dist < this.Player.StopRing)
			{
				inputDirection = -1.5f * (1 - dist / this.Player.StopRing) * toPlayer.Normalized();
			}
		}

		Vector2 targetVelocity = inputDirection * MaxSpeed;

		LinearVelocity = LinearVelocity.MoveToward(
			targetVelocity,
			Acceleration * (float)delta
		);
	}

	/// Select student - set player property, change color
	public void Select(Player player)
	{
		this.Player = player;
		this.Highlight();
	}

	/// Deselect student - remove itself from selection, set player to null, change color
	public void Deselect()
	{
		this.Player.Selection.Deselect(this);
		this.Player = null;
		this.UnHighlight();
	}

	private void Highlight()
	{
		var sprite = this.GetNodeOrNull<Sprite2D>("StudentSprite");
		if (sprite != null)
			sprite.Modulate = new Color(1, 0.6f, 0.6f);
	}

	private void UnHighlight()
	{
		var sprite = this.GetNodeOrNull<Sprite2D>("StudentSprite");
		if (sprite != null)
			sprite.Modulate = Colors.White;
	}
}
