using System.Collections;
using Anomaly.ECS;
using Anomaly.Features.Player.Components;
using raylib_beef;
using raylib_beef.Types;

namespace Anomaly.Features.Player.Systems
{
	class PlayerRepulsionSystem : System
	{
		private const float maxDist = 1000;
		private const float force = 2f;
		private const float oneOverMaxDist = 1f / maxDist;

		public this(World world) : base(world)
		{

		}

		public override void Tick(float deltaTime)
		{
			// scope Anomaly.Diagnostics.Profiler("PlayerRotationSystem");
			if (!Raylib.IsMouseButtonDown(0))
				return;

			var mousePosition = Raylib.GetMousePosition();
	
			world.Query(
				scope int[] (ComponentMeta<PlayerComponent>.Id, ComponentMeta<PositionComponent>.Id, ComponentMeta<VelocityComponent>.Id),
				scope (entity) =>
			{
				var position = ref world.GetComponent<PositionComponent>(entity);
				var velocity = ref world.GetComponent<VelocityComponent>(entity);

				var direction = position.Value - mousePosition;
				float distance = System.Math.Min((direction).LengthSqr(), maxDist);
				float influence = ((maxDist - distance) * oneOverMaxDist) * force;

				direction.Normalize(default);
				velocity.Value += direction * influence;
			});
		}
	}
}