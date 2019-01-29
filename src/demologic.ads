with Worlds; use Worlds;
with Entities; use Entities;
with Materials; use Materials;

package DemoLogic is
   
   type VisualCue is record
      X, Y, R : Integer;
      EntType : EntityTypes;
      Mat : Material;
   end record;

   function Inputs(W : in out World; Frozen : in out Boolean;
                   Cooldown : Integer; Cue : in out VisualCue) return Boolean;
   
   procedure ModeActions(Frozen : in out Boolean);
   
   procedure CreateEntity(W : in out World; X, Y : Integer; H : Natural);
   
   procedure DisplayEntity(X, Y : Integer; H : Natural; Cue : in out VisualCue);
   
   procedure CreateCircle(W : in out World; X, Y : Integer; H : Natural);

   procedure CreateRectangle(W : in out World; X, Y : Integer; H : Natural);
   
   procedure ChangeEnvironment(W : in out World);

end DemoLogic;
