using System.Collections;
using Anomaly.ECS.Collections;

namespace Anomaly.ECS
{
	typealias Entity = uint32;

	public class EntityManager
	{
		private Queue<Entity> entityQueue;
		private SparseArray entities;

		public readonly SparseArray Entities => entities;

		public this()
		{
			entityQueue = new Queue<Entity>(CacheSettings.MAX_ENTITIES);
			entities = new SparseArray(CacheSettings.MAX_ENTITIES);

			for(Entity e = 0; e < CacheSettings.MAX_ENTITIES; e++)
				entityQueue.Add(e);
		}

		public ~this()
		{
			delete entityQueue;
			delete entities;
		}

		public Entity CreateEntity()
		{
			System.Runtime.Assert(Entities.Count < CacheSettings.MAX_ENTITIES, "Max entities reached");

			Entity entity = entityQueue.PopFront();
			entities.Add(entity);

			return entity;
		}

		public void DestroyEntity(Entity entity)
		{
			System.Runtime.Assert(entity < CacheSettings.MAX_ENTITIES, "Entity out of range");

			entityQueue.Add(entity);
			entities.Remove(entity);
		}
	}
}