using System;
using System.Collections;
using Anomaly.ECS.Collections;

namespace Anomaly.ECS
{
	typealias ComponentEventDelegate = delegate void(Entity, ComponentId);

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

		private Dictionary<ComponentId, List<ComponentEventDelegate>> componentAddedEventMap;
		private Dictionary<ComponentId, List<ComponentEventDelegate>> componentRemovedEventMap;

		public int EntityCount => entityManager.Entities.Count;

		public this()
		{
			entityManager = new EntityManager();
			componentManager = new ComponentManager();
			systemManager = new SystemManager();

			componentManager.ComponentAddedEvent.Add(new (e, c) => OnComponentAddedEvent(e, c));
			componentManager.ComponentRemovedEvent.Add(new (e, c) => OnComponentRemovedEvent(e, c));

			componentAddedEventMap = new Dictionary<ComponentId, List<ComponentEventDelegate>>();
			componentRemovedEventMap = new Dictionary<ComponentId, List<ComponentEventDelegate>>();
		}

		public ~this()
		{
			componentManager.ComponentAddedEvent.Dispose();
			componentManager.ComponentRemovedEvent.Dispose();

			delete entityManager;
			delete componentManager;
			delete systemManager;

			for(var entry in componentAddedEventMap)
			{
				for(var d in entry.value)
					delete d;
				delete entry.value;
			}
			for(var entry in componentRemovedEventMap)
			{
				for(var d in entry.value)
					delete d;
				delete entry.value;
			}

			delete componentAddedEventMap;
			delete componentRemovedEventMap;
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

		public void RegisterComponent<T>() where T : struct, Component
		{
			componentManager.RegisterComponent<T>();
		}

		public ref T AddComponent<T>(Entity entity, T component) where T : struct, Component
		{
			return ref componentManager.AddComponent(entity, component);
		}

		public void RemoveComponent<T>(Entity entity) where T : struct, Component
		{
			componentManager.RemoveComponent<T>(entity);
		}

		public ref T GetComponent<T>(Entity entity) where T : struct, Component
		{
			return ref componentManager.GetComponent<T>(entity);
		}

		public bool HasComponent<T>(Entity entity) where T : struct, Component
		{
			return componentManager.HasComponent<T>(entity);
		}

		public void AddSystem(ISystem system)
		{
			systemManager.AddSystem(system);
		}

		public void RegisterToComponentAddedEvent<T>(ComponentEventDelegate eventDelegate) where T : struct, Component
		{
			List<ComponentEventDelegate> delegates;
			let componentId = ComponentMeta<T>.Id;
			if(!componentAddedEventMap.TryGetValue(componentId, out delegates))
			{
				delegates = new List<ComponentEventDelegate>();
				componentAddedEventMap.Add(ComponentMeta<T>.Id, delegates);
			}

			delegates.Add(eventDelegate);
		}

		public void RegisterToComponentRemovedEvent<T>(ComponentEventDelegate eventDelegate) where T : struct, Component
		{
			List<ComponentEventDelegate> delegates;
			let componentId = ComponentMeta<T>.Id;
			if(!componentRemovedEventMap.TryGetValue(componentId, out delegates))
			{
				delegates = new List<ComponentEventDelegate>();
				componentRemovedEventMap.Add(ComponentMeta<T>.Id, delegates);
			}

			delegates.Add(eventDelegate);
		}

		public void UnregisterFromComponentAddedEvent<T>(ComponentEventDelegate eventDelegate) where T : struct, Component
		{
			List<ComponentEventDelegate> delegates;
			if(componentAddedEventMap.TryGetValue(ComponentMeta<T>.Id, out delegates))
				delegates.Remove(eventDelegate);
		}

		public void UnregisterFromComponentRemovedEvent<T>(ComponentEventDelegate eventDelegate) where T : struct, Component
		{
			List<ComponentEventDelegate> delegates;
			if(componentRemovedEventMap.TryGetValue(ComponentMeta<T>.Id, out delegates))
				delegates.Remove(eventDelegate);
		}

		public void Query(int[] components, delegate void(Entity) entity)
		{
			if (components.Count == 0)
				return;

			// Sort components so that the first component is the one with the least entities
			// This will speed up the query as we will loop through the least amount of entities necessary
			var componentEntitiesList = scope List<(SimpleList<int>, int)>(components.Count);
			for(var component in components)
				componentEntitiesList.Add((componentManager.GetEntitiesWithComponent(component), component));
			componentEntitiesList.Sort(scope (lhs, rhs) => {return lhs.0.Count > rhs.0.Count ? 1 : -1;});

			var entities = componentEntitiesList[0].0;

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
					entity(e);
				}
			}
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

		private void OnComponentAddedEvent(Entity entity, ComponentId component)
		{
			List<ComponentEventDelegate> delegates;
			if(componentAddedEventMap.TryGetValue(component, out delegates))
				for(var d in delegates)
					d.Invoke(entity, component);
		}

		private void OnComponentRemovedEvent(Entity entity, ComponentId component)
		{
			List<ComponentEventDelegate> delegates;
			if(componentRemovedEventMap.TryGetValue(component, out delegates))
				for(var d in delegates)
					d.Invoke(entity, component);
		}
	}
}