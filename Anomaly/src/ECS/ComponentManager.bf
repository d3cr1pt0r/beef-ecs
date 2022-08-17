using System;
using Anomaly.ECS.Collections;

namespace Anomaly.ECS
{
	public static class ComponentIdCounter
	{
		public static int Counter = 0;
	}

	public static class ComponentMeta<T> where T : struct, Component
	{
		public static int Id { get; private set; }

		static this()
		{
			Id = ComponentIdCounter.Counter++;
		}
	}

	public class ComponentManager
	{
		private SparseSet<IComponentPool> componentsPool;

		public readonly SparseSet<IComponentPool> ComponentsPool => componentsPool;

		public this()
		{
			componentsPool = new SparseSet<IComponentPool>(CacheSettings.MAX_COMPONENTS);
		}

		public ~this()
		{
			componentsPool.Dispose();
			delete componentsPool;
		}

		public void RegisterComponent<T>() where T : Component
		{
			var componentId = ComponentMeta<T>.Id;

			System.Runtime.Assert(!componentsPool.Contains(componentId), scope $"Component {typeof(T)} already registered!");

			componentsPool.Add(componentId, new ComponentPool<T>(CacheSettings.MAX_ENTITIES));
		}

		public ref T AddComponent<T>(Entity entity, T component) where T : Component
		{
			var pool = GetComponentPool<T>();

			System.Runtime.Assert(!pool.Contains(entity), scope $"Component {typeof(T)} already added to entity {entity}!");

			return ref pool.Add(entity, component);
		}

		public void RemoveComponent<T>(Entity entity) where T : Component
		{
			GetComponentPool<T>().Remove(entity);
		}

		public ref T GetComponent<T>(Entity entity) where T : Component
		{
			var componentId = ComponentMeta<T>.Id;
			return ref ((ComponentPool<T>)componentsPool[componentId]).Get(entity);
		}

		public bool HasComponent<T>(Entity entity) where T : Component
		{
			return HasComponent(entity, ComponentMeta<T>.Id);
		}

		public bool HasComponent(Entity entity, int componentId)
		{
			return componentsPool[componentId].Contains(entity);
		}

		public void EntityDestroyed(Entity entity)
		{
			var componentsPoolValues = componentsPool.Values;
			for(int i=0; i<componentsPoolValues.Count; i++)
				componentsPoolValues[i].Remove(entity);
		}

		public SimpleList<int> GetEntitiesWithComponent(int componentId)
		{
			return GetComponentPool(componentId).Entities;
		}

		private ComponentPool<T> GetComponentPool<T>() where T : Component
		{
			var componentId = ComponentMeta<T>.Id;

			System.Runtime.Assert(componentsPool.Contains(componentId), scope $"Component {typeof(T)} not registered!");

			return (ComponentPool<T>) componentsPool[componentId];
		}

		private IComponentPool GetComponentPool(int componentId)
		{
			System.Runtime.Assert(componentsPool.Contains(componentId), scope $"Component with id={componentId} not registered!");

			return componentsPool[componentId];
		}
	}
}