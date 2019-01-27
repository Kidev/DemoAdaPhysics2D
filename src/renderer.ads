with Entities; use Entities;
with Worlds; use Worlds;
with Vectors2D; use Vectors2D;
with HAL.Bitmap; use HAL.Bitmap;
with Materials; use Materials;

package Renderer is

   -- Displays the entities passed
   procedure Render(Ents : EArray);

   -- Failsafe translation to int Coords
   function GetIntCoords(flCoords : Vec2D) return Point;

   -- Gets the color appropriate for the material
   function GetColor(Mat : in Material) return Bitmap_Color;

   -- Tells if an entity is invalid
   function InvalidEnt(E : access Entity'Class) return Boolean;

   -- Gets the background color appropriate for the env type
   function GetEnvColor(Env : Environment) return Bitmap_Color;

end Renderer;
