using Godot;
using System;

public partial class Student : CharacterBody2D, Selectable
{
	[Export] public float MaxSpeed = 100f;
	[Export] public float Acceleration = 500f;
	[Export] public float Friction = 400f;
	
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
		
		/*
			Player too far - deselect itself
			Player too close - stop moving
			Player in range - move towards player, speed up when player is getting away
		*/
		
		if (this.Player != null) {
			Vector2 toPlayer = this.Player.GlobalPosition - this.GlobalPosition;
			
			float dist = toPlayer.Length();
			
			if (dist > this.Player.DeselectRing)
			{
				this.Deselect();
			}
			else if (dist > this.Player.StopRing)
			{
				inputDirection = toPlayer.Normalized();
				if (dist > this.Player.CatchUpRing)
				{
					inputDirection *= 1.5f;
				}
			}
			else if (dist < this.Player.StopRing) {
				inputDirection = -1.5f * (1 - dist / this.Player.StopRing) * toPlayer.Normalized();
			}
		}

		if (inputDirection != Vector2.Zero)
		{
			// Accelerate toward target velocity
			Velocity = Velocity.MoveToward(
				inputDirection * MaxSpeed,
				Acceleration * (float)delta
			);
		}
		else
		{
			// Apply friction when no input
			Velocity = Velocity.MoveToward(
				Vector2.Zero,
				Friction * (float)delta
			);
		}

		MoveAndSlide();
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
