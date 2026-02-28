using Godot;

public partial class MainScene : Node2D
{
	[Export] public PackedScene StudentScene;
	[Export] public PackedScene PlayerScene;

	public override void _Ready()
	{
		SpawnStudents(10);
		SpawnPlayer();
	}
	
	/// Spawns a player inside the main scene
	private void SpawnPlayer()
	{
		var player = PlayerScene.Instantiate<Player>();
		player.GlobalPosition = new Vector2(
				500, 500
			);
		AddChild(player);
	}

	/// Spawns students inside the main scene
	private void SpawnStudents(int count)
	{
		for (int i = 0; i < count; i++)
		{
			var student = StudentScene.Instantiate<Student>();

			student.GlobalPosition = new Vector2(
				GD.RandRange(0, 1100),
				GD.RandRange(0, 600)
			);

			AddChild(student);
		}
	}
}
