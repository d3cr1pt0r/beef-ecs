using System;
using System.Collections;
using Anomaly.ECS;
using Anomaly.Features.Player.Components;
using raylib_beef;
using raylib_beef.Types;

namespace Anomaly.Features.Player.Systems
{
	class PlayerRespawnSystem : System
	{
		private Random random;

		public this(World world) : base(world)
		{
			random = new Random();
		}

		public ~this()
		{
			delete random;
		}

		public override void Tick(float deltaTime)
		{
			// scope Anomaly.Diagnostics.Profiler("PlayerDestroySystem");
			let screenWidth = Raylib.GetScreenWidth();
			let screenHeight = Raylib.GetScreenHeight();
	
			world.Query(
				scope int[] (ComponentMeta<PlayerComponent>.Id, ComponentMeta<PositionComponent>.Id),
				scope (entity) =>
			{
				var position = ref world.GetComponent<PositionComponent>(entity);

				if (position.X < 50 ||
					position.X > screenWidth - 50 ||
					position.Y < 50 ||
					position.Y > screenHeight - 50)
				{
					world.DestroyEntity(entity);

					var screenWidth = Raylib.GetScreenWidth();
					PlayerService.CreatePlayerEntity(world, random, 100, screenWidth - 100, 100, screenHeight - 100);
				}
			});
		}
	}
}