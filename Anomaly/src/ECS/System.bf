using System.Collections;

namespace Anomaly.ECS
{
	public interface ISystem
	{
		void Tick(float deltaTime);
	}

	public abstract class System : ISystem
	{
		protected World world;

		public this(World world)
		{
			this.world = world;
		}

		public abstract void Tick(float deltaTime);
	}
}