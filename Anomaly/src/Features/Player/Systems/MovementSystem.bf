using System;
using System.Collections;
using Anomaly.ECS;
using Anomaly.Features.Player.Components;
using raylib_beef.Types;

namespace Anomaly.Features.Player.Systems
{
	class MovementSystem : System
	{
		public this(World world) : base(world)
		{

		}

		public override void Tick(float deltaTime)
		{
			// scope Anomaly.Diagnostics.Profiler("MovementSystem");
	
			world.Query(
				scope int[] (ComponentMeta<PositionComponent>.Id, ComponentMeta<VelocityComponent>.Id),
				scope (entity) =>
			{
				var position = ref world.GetComponent<PositionComponent>(entity);
				var velocity = ref world.GetComponent<VelocityComponent>(entity);

				velocity.X -= velocity.X * 2f * deltaTime;
				velocity.Y -= velocity.Y * 2f * deltaTime;

				position.X += velocity.X * deltaTime;
				position.Y += velocity.Y * deltaTime;
			});
		}
	}
}