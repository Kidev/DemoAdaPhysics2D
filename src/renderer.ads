with Worlds; use Worlds;
with Vectors2D; use Vectors2D;
with HAL.Bitmap; use HAL.Bitmap;

package Renderer is

   -- Displays the entities passed
   procedure Render(Ents : EArray);
   function getIntCoords(flCoords : Vec2D) return Point;

end Renderer;
