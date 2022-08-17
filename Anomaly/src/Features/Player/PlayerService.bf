using System;
using Anomaly.ECS;
using Anomaly.Features.Player.Components;
using raylib_beef.Types;

namespace Anomaly.Features.Player
{
	public static class PlayerService
	{
		public static Entity CreatePlayerEntity(World world, Random random, int minX, int maxX, int minY, int maxY)
		{
			var color = Color(20, (uint8)random.Next(100, 255), 20, 255);
			var posX = random.Next(minX, maxX);
			var posY = random.Next(minY, maxY);

			var entity = world.CreateEntity();
			world.AddComponent(entity, PlayerComponent() {Color = color, InitialPosition = .(posX, posY)});
			world.AddComponent(entity, PositionComponent() { Value = .(posX, posY) });
			world.AddComponent(entity, VelocityComponent() { Value = .(0, 0) });
			world.AddComponent(entity, RotationComponent() {Value = random.Next(0, 360)});

			return entity;
		}
	}
}