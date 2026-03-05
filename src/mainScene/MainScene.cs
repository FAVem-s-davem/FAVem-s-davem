using Godot;

public partial class MainScene : Node2D
{
	[Export] public PackedScene StudentScene;
	[Export] public PackedScene PlayerScene;
	[Export] public PackedScene MapScene;

	public override void _Ready()
	{
		SpawnStudents(10);
		SpawnPlayer();
		var map = MapScene.Instantiate<MapObject>();

		map.Init(new Vector2[]
		{
			new Vector2(0,0),
			new Vector2(700,0),
			new Vector2(700,200),
			new Vector2(500,200),
			new Vector2(500,500),
			new Vector2(700,500),
			new Vector2(700,700),
			new Vector2(0,700)
		});

		AddChild(map);
		
		var map2 = MapScene.Instantiate<MapObject>();

		map2.Init(new Vector2[]
		{
			new Vector2(100,100),
			new Vector2(200,100),
			new Vector2(200,200),
			new Vector2(100,200),
		});

		AddChild(map2);
	}
	
	/// Spawns a player inside the main scene
	private void SpawnPlayer()
	{
		var player = PlayerScene.Instantiate<Player>();
		player.GlobalPosition = new Vector2(
			100, 100
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
