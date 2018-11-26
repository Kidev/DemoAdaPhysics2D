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

   -- Checks if entities are valid: if not, they are removed
   procedure CheckEntities(W : in out World);

   -- Tells if an entity is invalid
   function InvalidEnt(E : not null access Entity'Class) return Boolean;

end Renderer;
