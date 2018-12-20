with Worlds; use Worlds;

package GameLogic is

   function Inputs(W : in out World; Frozen : in out Boolean; Cooldown : Integer) return Boolean;
   
   procedure ModeActions(Frozen : in out Boolean);
   
   procedure CreateEntity(W : in out World; X, Y, Hold : Integer);
   
   procedure DisplayEntity(X, Y, Hold : Integer);
   
   procedure DisplayCircle(X, Y, Hold : Integer);
   
   procedure CreateCircle(W : in out World; X, Y, Hold : Integer);
   
   procedure DisplayRectangle(X, Y, Hold : Integer);

   procedure CreateRectangle(W : in out World; X, Y, Hold : Integer);

end GameLogic;
