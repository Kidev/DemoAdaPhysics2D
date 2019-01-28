with Entities; use Entities;
with Worlds; use Worlds;
with Vectors2D; use Vectors2D;
with HAL.Bitmap; use HAL.Bitmap;
with Materials; use Materials;
with DemoLogic; use DemoLogic;

package Renderer is

   -- Displays the entities passed
   procedure Render(W : in out World; Cue : VisualCue);

   procedure RenderList(L : ListAcc);

   procedure RenderCue(Cue : VisualCue);

   -- Failsafe translation to int Coords
   function GetIntCoords(flCoords : Vec2D) return Point;

   -- Gets the color appropriate for the material
   function GetColor(Mat : in Material) return Bitmap_Color;

   -- Tells if an entity is invalid
   function InvalidEnt(E : access Entity'Class) return Boolean;

end Renderer;
