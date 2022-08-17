using System;
using System.Collections;
using raylib_beef;
using raylib_beef.Enums;
using raylib_beef.Types;
using Anomaly.ECS;
using Anomaly.Features.Player.Systems;
using Anomaly.Features.Player.Components;

namespace Anomaly
{

	class Program
	{
		public static int Main(String[] args)
		{
			IApplication application = scope EcsTestApplication();
			application.Run();

			return 0;
		}
	}
}