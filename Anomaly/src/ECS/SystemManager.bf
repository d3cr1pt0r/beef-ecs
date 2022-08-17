using System.Collections;

namespace Anomaly.ECS
{
	public class SystemManager
	{
		public List<ISystem> systems;

		public this()
		{
			systems = new List<ISystem>(CacheSettings.MAX_SYSTEMS);
		}

		public ~this()
		{
			for(var system in systems)
				delete system;

			delete systems;
		}

		public void AddSystem(ISystem system)
		{
			systems.Add(system);
		}

		public void RemoveSystem(ISystem system)
		{
			systems.Remove(system);
		}

		public void Tick(float deltaTime)
		{
			for(var system in systems)
				system.Tick(deltaTime);
		}
	}
}