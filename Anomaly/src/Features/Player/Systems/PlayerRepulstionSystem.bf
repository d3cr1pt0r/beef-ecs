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

				var direction = Vector2(position.X, position.Y) - mousePosition;
				float distance = System.Math.Min((direction).LengthSqr(), maxDist);
				float influence = ((maxDist - distance) / maxDist) * force;

				direction.Normalize(default);
				velocity.X += direction.x * influence;
				velocity.Y += direction.y * influence;
			});
		}
	}
}