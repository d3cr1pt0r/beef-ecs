using System.Collections;
using Anomaly.ECS;
using Anomaly.Features.Player.Components;

namespace Anomaly.Features.Player.Systems
{
	class PlayerRotationSystem : System
	{
		private const float speed = 100;

		public this(World world) : base(world)
		{

		}

		public override void Tick(float deltaTime)
		{
			// scope Anomaly.Diagnostics.Profiler("PlayerRotationSystem");
	
			world.Query(
				scope int[] (ComponentMeta<PlayerComponent>.Id, ComponentMeta<RotationComponent>.Id),
				scope (entity) =>
			{
				var rotation = ref world.GetComponent<RotationComponent>(entity);
				rotation.Value += speed * deltaTime;
			});
		}
	}
}