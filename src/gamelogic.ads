with Worlds; use Worlds;

package GameLogic is

   function Inputs(W : in out World; Frozen : in out Boolean; Cooldown : Integer) return Boolean;
   
   procedure ModeActions(Frozen : in out Boolean);
   
   procedure CreateEntity(W : in out World; X, Y : Integer; H : Natural);
   
   procedure DisplayEntity(X, Y : Integer; H : Natural);
   
   procedure DisplayCircle(X, Y : Integer; H : Natural);
   
   procedure CreateCircle(W : in out World; X, Y : Integer; H : Natural);
   
   procedure DisplayRectangle(X, Y : Integer; H : Natural);

   procedure CreateRectangle(W : in out World; X, Y : Integer; H : Natural);

end GameLogic;
