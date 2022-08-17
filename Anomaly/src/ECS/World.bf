using System;
using System.Collections;
using Anomaly.ECS.Collections;

namespace Anomaly.ECS
{
	public static class CacheSettings
	{
		public const int MAX_ENTITIES = 100000;
		public const int MAX_COMPONENTS = 64;
		public const int MAX_SYSTEMS = 100;
	}

	public class World
	{
		private EntityManager entityManager;
		private ComponentManager componentManager;
		private SystemManager systemManager;

		private Dictionary<String, List<Entity>> queryCache;

		public int EntityCount => entityManager.Entities.Count;

		public this()
		{
			entityManager = new EntityManager();
			componentManager = new ComponentManager();
			systemManager = new SystemManager();

			queryCache = new Dictionary<String, List<Entity>>();
		}

		public ~this()
		{
			delete entityManager;
			delete componentManager;
			delete systemManager;

			for(var entry in queryCache)
			{
				delete entry.key;
				delete entry.value;
			}
			delete queryCache;
		}

		public Entity CreateEntity()
		{
			return entityManager.CreateEntity();
		}

		public void DestroyEntity(Entity entity)
		{
			componentManager.EntityDestroyed(entity);
			entityManager.DestroyEntity(entity);
		}

		public void RegisterComponent<T>() where T : Component
		{
			componentManager.RegisterComponent<T>();
		}

		public ref T AddComponent<T>(Entity entity, T component) where T : Component
		{
			return ref componentManager.AddComponent(entity, component);
		}

		public void RemoveComponent<T>(Entity entity) where T : Component
		{
			componentManager.RemoveComponent<T>(entity);
		}

		public ref T GetComponent<T>(Entity entity) where T : Component
		{
			return ref componentManager.GetComponent<T>(entity);
		}

		public bool HasComponent<T>(Entity entity) where T : Component
		{
			return componentManager.HasComponent<T>(entity);
		}

		public void AddSystem(ISystem system)
		{
			systemManager.AddSystem(system);
		}

		public void Query(int[] components, delegate void(Entity) entity)
		{
			if (components.Count == 0)
				return;

			/*var cs = scope String(components.Count);
			for(var value in components)
				cs.Append(value);

			List<Entity> cachedEntities;
			if (queryCache.TryGetValue(cs, out cachedEntities))
			{
				for(var e in cachedEntities)
					entity(e);
				return;
			}*/

			// Sort components so that the first component is the one with the least entities
			// This will speed up the query as we will loop through the least amount of entities necessary
			var componentEntitiesList = scope List<(SimpleList<int>, int)>(components.Count);
			for(var component in components)
				componentEntitiesList.Add((componentManager.GetEntitiesWithComponent(component), component));
			componentEntitiesList.Sort(scope (lhs, rhs) => {return lhs.0.Count > rhs.0.Count ? 1 : -1;});

			var entities = componentEntitiesList[0].0;

			/*cachedEntities = new List<Entity>(entities.Count);*/

			for(var i=0; i<entities.Count; i++)
			{
				var e = (Entity)entities[i];
				var match = true;

				for(var j=1; j<componentEntitiesList.Count; j++)
				{
					if (!componentManager.HasComponent(e, componentEntitiesList[j].1))
					{
						match = false;
						break;
					}
				}

				if (match)
				{
					/*cachedEntities.Add(e);*/
					entity(e);
				}
			}

			/*var csc = new String(cs);
			queryCache.Add(csc, cachedEntities);*/
		}

		public void Query(int[] includeComponents, int[] excludeComponents, delegate void(Entity) entity)
		{
			if (includeComponents.Count == 0)
				return;

			// Sort components so that the first component is the one with the least entities
			// This will speed up the query as we will loop through the least amount of entities necessary
			var componentEntitiesList = scope List<(SimpleList<int>, int)>(includeComponents.Count);
			for(var component in includeComponents)
				componentEntitiesList.Add((componentManager.GetEntitiesWithComponent(component), component));
			componentEntitiesList.Sort(scope (lhs, rhs) => {return lhs.0.Count > rhs.0.Count ? 1 : -1;});

			var entities = componentEntitiesList[0].0;

			for(var i=0; i<entities.Count; i++)
			{
				var e = (Entity) entities[i];
				var match = true;

				for(var j=0; j<excludeComponents.Count; j++)
				{
					if (componentManager.HasComponent(e, excludeComponents[j]))
					{
						match = false;
						break;
					}
				}

				if (!match)
					continue;

				for(var j=1; j<componentEntitiesList.Count; j++)
				{
					if (!componentManager.HasComponent(e, componentEntitiesList[j].1))
					{
						match = false;
						break;
					}
				}

				if (match)
					entity((uint32)e);
			}
		}

		public void Tick(float deltaTime)
		{
			systemManager.Tick(deltaTime);
		}
	}
}