using System;

using raylib_beef;
using raylib_beef.Types;

using Anomaly.ECS;
using Anomaly.ECS.Collections;
using Anomaly.Features.Player.Components;
using Anomaly.Features.Player.Systems;
using Anomaly.Features.Player;

namespace Anomaly
{
	class EcsTestApplication : IApplication
	{
		public void Run()
		{
			Raylib.SetConfigFlags(.FLAG_WINDOW_RESIZABLE);
			Raylib.InitWindow(800, 600, "Anomaly");
			Raylib.SetTargetFPS(144);

			var screenWidth = Raylib.GetScreenWidth();
			var screenHeight = Raylib.GetScreenHeight();
			var world = scope World();

			world.RegisterComponent<PlayerComponent>();
			world.RegisterComponent<PositionComponent>();
			world.RegisterComponent<VelocityComponent>();
			world.RegisterComponent<RotationComponent>();

			var random = scope Random();
			for(int i=0; i<10; i++)
				PlayerService.CreatePlayerEntity(world, random, 100, screenWidth - 100, 100, screenHeight - 100);

			world.AddSystem(new MovementSystem(world));
			world.AddSystem(new PlayerRotationSystem(world));
			world.AddSystem(new PlayerRepulsionSystem(world));
			world.AddSystem(new DrawPlayerSystem(world));
			world.AddSystem(new PlayerRespawnSystem(world));

			while (!Raylib.WindowShouldClose())
			{
				Raylib.BeginDrawing();

				Raylib.ClearBackground(.(52, 52, 52, 255));

				float deltaTime = Raylib.GetFrameTime();
				world.Tick(deltaTime);

				Raylib.DrawText(scope $"Fps: {Raylib.GetFPS()}", 10, 10, 14, .GREEN);
				Raylib.DrawText(scope $"DT: {deltaTime}", 10, 30, 14, .GREEN);
				Raylib.DrawText(scope $"Entities: {world.EntityCount}", 10, 50, 14, .GREEN);
				Raylib.EndDrawing();
			}

			Raylib.CloseWindow();
		}
	}
}