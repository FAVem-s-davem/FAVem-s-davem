using System.Collections.Generic;
using System.Linq;

/// Handles selection and deselection of students
public class SelectionManager
{
	private readonly Player owner;
	private readonly List<Selectable> selected = new();

	/// Constructor, sets owner
	public SelectionManager(Player owner)
	{
		this.owner = owner;
	}

	/// Clear selection and select new students
	public void Select(IEnumerable<Selectable> students)
	{
		Clear();

		foreach (var s in students)
		{
			s.Select(owner);
			selected.Add(s);
		}
	}

	/// Clear selection using student.Deselect
	public void Clear()
	{
		foreach (var s in selected.ToList())
			s.Deselect();

		selected.Clear();
	}
	
	/// Append student to selection
	public void Add(IEnumerable<Selectable> students)
	{
		foreach (var s in students)
		{
			if (!selected.Contains(s))
			{
				s.Select(owner);
				selected.Add(s);
			}
		}
	}
	
	/// Remove student from selection
	public void Deselect(Selectable student)
	{
		if (this.selected.Contains(student))
		{
			this.selected.Remove(student);
		}
	}
}
