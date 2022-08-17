using Anomaly.ECS;
using raylib_beef.Types;

namespace Anomaly.Features.Player.Components
{
	public struct PlayerComponent : Component
	{
		public Color Color;
		public Vector2 InitialPosition;
	}
}