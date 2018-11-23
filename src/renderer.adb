with Entities; use Entities;
with Vectors2D; use Vectors2D;
with LCD_Std_Out;

package body Renderer is

   procedure Render(Ents : EArray)
   is
      E : access Entity'Class;
   begin
      
      for I in Ents'Range loop

         E := Ents(I);
         LCD_Std_Out.Put_Line(+E.all.Coords);  

      end loop;
      
   end Render;

end Renderer;
