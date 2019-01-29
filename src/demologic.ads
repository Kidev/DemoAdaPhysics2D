with Worlds; use Worlds;
with Entities; use Entities;
with Materials; use Materials;
with Menus; use Menus;

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
   
   procedure ShowActionMenu;
   
   procedure ToggleGravity(This : in out Menu);
   
   function GetMatName(This : Material) return String;
   
   procedure GotoNextMat(This : in out Menu);
   
   function GetGravityStr return String;

end DemoLogic;
