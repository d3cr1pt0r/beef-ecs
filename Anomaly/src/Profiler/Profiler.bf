using System;
using System.Diagnostics;

namespace Anomaly.Diagnostics
{
	class Profiler
	{
		private Stopwatch stopwatch;
		private String name;

		public this(String name)
		{
			this.name = name;

			stopwatch = new Stopwatch();
			stopwatch.Start();
		}

		public ~this()
		{
			Stop();

			delete stopwatch;
		}

		public void Stop()
		{
			stopwatch.Stop();
			Console.WriteLine($"Profiler: name={name} timeMs={stopwatch.ElapsedMilliseconds}");
		}
	}
}