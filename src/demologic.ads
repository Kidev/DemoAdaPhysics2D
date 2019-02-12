with Worlds; use Worlds;
with Entities; use Entities;
with Materials; use Materials;
with Menus; use Menus;
with Vectors2D; use Vectors2D;
with Links; use Links;

package DemoLogic is
   
   Hold : Natural := 0;
   LastX, LastY : Integer := 0;
   GlobalGravity : Vec2D := (0.0, 9.81);
   MaxHold : constant Natural := 40;
   EntCreatorMat : Materials.Material := Materials.BALLOON;
   EntEditorMat : Materials.Material := Materials.VACUUM;
   EntLinkerType : LinkTypes := LTRope;
   EntLinkerSelected : EntityClassAcc := null;
   type Modes is (M_Frozen, M_Disabled, M_Circle, M_Rectangle, M_Edit, M_Link);
   Mode : Modes := M_Disabled;
   CurWorld : World;
   Quit : Boolean := False;
   
   type VisualCue is record
      X, Y, R : Integer;
      EntType : EntityTypes;
      Mat : Material;
   end record;

   function Inputs(W : in out World; Frozen : in out Boolean;
                   Cooldown : Integer; Cue : in out VisualCue) return Boolean;
   
   procedure ModeActions(Frozen : in out Boolean);
   
   procedure CreateEntity(W : in out World; X, Y : Integer; H : Natural)
     with Pre => X >= 0 and X <= 240 and Y >= 0 and Y <= 320 and H <= MaxHold;
   
   procedure DisplayEntity(X, Y : Integer; H : Natural; Cue : in out VisualCue)
     with Pre => X >= 0 and X <= 240 and Y >= 0 and Y <= 320 and H <= MaxHold;
   
   procedure CreateCircle(W : in out World; X, Y : Integer; H : Natural)
     with Pre => X >= 0 and X <= 240 and Y >= 0 and Y <= 320 and H <= MaxHold;

   procedure CreateRectangle(W : in out World; X, Y : Integer; H : Natural)
     with Pre => X >= 0 and X <= 240 and Y >= 0 and Y <= 320 and H <= MaxHold;
   
   procedure ShowActionMenu;
   
   procedure ToggleGravity(This : in out Menu);
   
   function GetMatName(This : Material) return String;
   
   function GetLinkTypeName(This : LinkTypes) return String;
   
   procedure GotoNextSolidMat(This : in out Menu)
     with Post => IsSolidMaterial(EntCreatorMat);
   
   procedure GotoNextMat(This : in out Menu);
   
   procedure GotoNextLinkType(This : in out Menu);
   
   function GetGravityStr return String;
   
   procedure QuitDemo(This : in out Menu);

private
   
   procedure SetLEDs(R, G : Boolean);
   
   procedure TryToEditAt(W : in out World; X, Y : Integer);
   
   procedure TryToLinkAt(W : in out World; X, Y : Integer);

end DemoLogic;
