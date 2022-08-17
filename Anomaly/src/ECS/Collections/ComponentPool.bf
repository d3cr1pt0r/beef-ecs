using System;

namespace Anomaly.ECS.Collections
{
	public interface IComponentPool
	{
		readonly SimpleList<int> Entities { get; }

		bool Contains(int id);
		void Remove(int id);
		void Clear();
	}

	public class ComponentPool<T> : IComponentPool
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

		public void Remove(int id)
		{
			components.Remove(id);
		}

		public void Clear()
		{
			components.Clear();
		}
	}
}