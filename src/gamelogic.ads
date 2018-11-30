with Worlds; use Worlds;
with Vectors2D; use Vectors2D;

package GameLogic is

   procedure Inputs(W : in out World);
   
   function GetVecFromCenter(X, Y : Integer) return Vec2D;
   
   function Clamp(Value, Min, Max : Float) return Float;

end GameLogic;
