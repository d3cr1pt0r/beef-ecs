using System;

namespace Anomaly.ECS.Collections
{
	public interface IComponentPool
	{
		readonly SimpleList<int> Entities { get; }

		bool Contains(int id);
		int Remove(int id);
		void Clear();
	}

	public class ComponentPool<T> : IComponentPool where T : struct, Component
	{
		private SparseSet<T> components;

		public readonly SimpleList<int> Entities => components.Indices;

		public this(int capacity)
		{
			components = new SparseSet<T>(CacheSettings.MAX_ENTITIES);
		}

		public ~this()
		{
			components.Dispose();
			delete components;
		}

		public ref T Add(int id, T value)
		{
			return ref components.Add(id, value);
		}

		public ref T Get(int id)
		{
			return ref components[id];
		}

		public bool Contains(int id)
		{
			return components.Contains(id);
		}

		public int Remove(int id)
		{
			components.Remove(id);
			return ComponentMeta<T>.Id;
		}

		public void Clear()
		{
			components.Clear();
		}
	}
}