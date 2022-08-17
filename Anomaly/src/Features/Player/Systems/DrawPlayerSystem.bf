using System.Collections;
using System.Diagnostics;
using Anomaly.ECS;
using Anomaly.Features.Player.Components;

using raylib_beef;
using raylib_beef.Types;

namespace Anomaly.Features.Player.Systems
{
	class DrawPlayerSystem : System
	{
		private const float maxVelocity = 10000;

		public this(World world) : base(world)
		{
			
		}

		public override void Tick(float deltaTime)
		{
			// scope Anomaly.Diagnostics.Profiler("DrawPlayerSystem");

			world.Query(
				scope int[] (ComponentMeta<PlayerComponent>.Id, ComponentMeta<PositionComponent>.Id, ComponentMeta<RotationComponent>.Id, ComponentMeta<VelocityComponent>.Id),
				scope (entity) =>
			{
				var position = ref world.GetComponent<PositionComponent>(entity);
				var rotation = ref world.GetComponent<RotationComponent>(entity);
				var velocity = ref world.GetComponent<VelocityComponent>(entity);

				float velocityLengthSqr = velocity.Value.LengthSqr();
				var color = Color.LerpBlend(.GREEN, .RED, velocityLengthSqr / maxVelocity);

				int32 posX = (int32) position.Value.x;
				int32 posY = (int32) position.Value.y;

				Raylib.DrawRectanglePro(.(posX, posY, 10, 10), .(0,0), rotation.Value, color);
			});
		}
	}
}