using Godot;

public partial class MapObject : StaticBody2D
{
	private Vector2[] _polygon;

	public void Init(Vector2[] polygon)
	{
		_polygon = polygon;
	}

	public override void _Ready()
	{
		if (_polygon == null)
			return;

		CreateWalls();
		QueueRedraw();
	}

	private void CreateWalls()
	{
		for (int i = 0; i < _polygon.Length; i++)
		{
			Vector2 a = _polygon[i];
			Vector2 b = _polygon[(i + 1) % _polygon.Length];

			var shape = new SegmentShape2D
			{
				A = a,
				B = b
			};

			var collision = new CollisionShape2D
			{
				Shape = shape
			};

			AddChild(collision);
		}
	}

	public override void _Draw()
	{
		if (_polygon == null) return;

		for (int i = 0; i < _polygon.Length; i++)
		{
			DrawLine(_polygon[i], _polygon[(i + 1) % _polygon.Length], Colors.Red, 5);
		}
	}
}
