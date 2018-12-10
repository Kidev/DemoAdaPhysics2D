with Worlds; use Worlds;

package GameLogic is

   function Inputs(W : in out World; Frozen : in out Boolean; Cooldown : Integer) return Boolean;
   
   procedure DisplayCircle(X, Y, Hold : Integer);
   
   procedure CreateCircle(W : in out World; X, Y, Hold : Integer);

end GameLogic;
