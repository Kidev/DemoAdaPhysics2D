with STM32.Board; use STM32.Board;

with Entities; use Entities;
with Circles; use Circles;
with Rectangles; use Rectangles;

package body Renderer is

   procedure Render(Ents : EArray)
   is
      E : access Entity'Class;
   begin
      
      for I in Ents'Range loop

         E := Ents(I);
         case E.all.EntityType is

            when EntCircle =>
               declare
                  C : constant CircleAcc := CircleAcc(E);
               begin
                  Display.Hidden_Buffer(1).Set_Source
                    (HAL.Bitmap.Red);
                  Display.Hidden_Buffer(1).Fill_Circle
                    (
                     Center => getIntCoords(C.all.Coords),
                     Radius => Integer(C.all.Radius)
                    );
               end;
               
            when EntRectangle =>
               declare
                  R : constant RectangleAcc := RectangleAcc(E);
               begin
                  Display.Hidden_Buffer(1).Set_Source
                    (HAL.Bitmap.Green);
                  Display.Hidden_Buffer(1).Fill_Rect
                    (
                     Area => (
                              Position => getIntCoords(R.all.Coords),
                              Height => Natural(R.all.GetHeight),
                              Width => Natural(R.all.GetWidth)
                             )
                    );
               end;
               
         end case;

      end loop;
      Display.Update_Layer(1, Copy_Back => False);
      
   end Render;
   
   function getIntCoords(flCoords : Vec2D) return Point
   is
   begin
      return Point'(Natural(flCoords.x), Natural(flCoords.y));
   end getIntCoords;

end Renderer;
