with Entities; use Entities;
with Worlds; use Worlds;
with Vectors2D; use Vectors2D;
with HAL.Bitmap; use HAL.Bitmap;
with Materials; use Materials;
with DemoLogic; use DemoLogic;
with Links; use Links;

package Renderer is

   -- Displays the entities passed
   procedure Render(W : in out World; Cue : VisualCue);

   procedure RenderList(L : EntsListAcc; Selected : EntityClassAcc := null);

   procedure RenderCue(Cue : VisualCue);

   procedure RenderLinksList(L : LinksListAcc);

   -- Failsafe translation to int Coords
   function GetIntCoords(flCoords : Vec2D) return Point
     with Post => GetIntCoords'Result.X <= 240 and GetIntCoords'Result.Y <= 320;

   function GetBezierPoint(Link : LinkAcc; i : Natural; n : Positive; UseMul : Float := 0.0) return Point;

   -- Gets the color appropriate for the material
   function GetColor(Mat : in Material) return Bitmap_Color;

   -- Gets the color for the link
   function GetLinkColor(L : LinkAcc) return Bitmap_Color;

   function GetCenteredPos(E : EntityClassAcc) return Point;

   -- Tells if an entity is invalid
   function InvalidEnt(E : EntityClassAcc) return Boolean;

   procedure DrawRope(Link : LinkAcc);

   procedure DrawSpring(Link : LinkAcc);

end Renderer;
