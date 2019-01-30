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

   procedure RenderList(L : EntsListAcc);

   procedure RenderCue(Cue : VisualCue);

   procedure RenderLinksList(L : LinksListAcc);

   -- Failsafe translation to int Coords
   function GetIntCoords(flCoords : Vec2D) return Point
     with Post => GetIntCoords'Result.X <= 240 and GetIntCoords'Result.Y <= 320;

   -- Gets the color appropriate for the material
   function GetColor(Mat : in Material) return Bitmap_Color;

   -- Gets the color for the link
   function GetLinkColor(L : LinkAcc) return Bitmap_Color;

   function GetCenteredPos(E : access Entity'Class) return Point;

   -- Tells if an entity is invalid
   function InvalidEnt(E : access Entity'Class) return Boolean;

end Renderer;
