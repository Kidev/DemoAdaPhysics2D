with STM32.Board; use STM32.Board;
with Circles; use Circles;
with Rectangles; use Rectangles;

package body Renderer is

   procedure Render(Ents : EArray)
   is
      E : access Entity'Class;
   begin
      
      for I in Ents'Range loop

         E := Ents(I);
         
         Display.Hidden_Buffer(1).Set_Source(GetColor(E.Mat));
         
         case E.all.EntityType is

            when EntCircle =>
               declare
                  C : constant CircleAcc := CircleAcc(E);
               begin
                  Display.Hidden_Buffer(1).Fill_Circle
                    (
                     Center => GetIntCoords(C.all.Coords),
                     Radius => Integer(C.all.Radius)
                    );
               end;
               
            when EntRectangle =>
               declare
                  R : constant RectangleAcc := RectangleAcc(E);
               begin
                  Display.Hidden_Buffer(1).Fill_Rect
                    (
                     Area => (
                              Position => GetIntCoords(R.all.Coords),
                              Height => Natural(R.all.GetHeight),
                              Width => Natural(R.all.GetWidth)
                             )
                    );
               end;
               
         end case;

      end loop;
      Display.Update_Layer(1, Copy_Back => False);
      
   end Render;
   
   function GetColor(Mat : in Material) return Bitmap_Color
   is
   begin
      case Mat.MType is
         when MTStatic => return Green;
         when MTSteel => return Silver;
         when MTIce => return Blue;
         when MTConcrete => return Grey;
         when MTRubber => return Red;
         when MTWood => return Brown;
      end case;
   end GetColor;
   
   procedure CheckEntities(W : in out World)
   is
   begin
      loop
         declare
            Ents : constant EArray := W.GetEntities;
            Edited : Boolean := False;
         begin
            for E of Ents loop
               if InvalidEnt(E) then
                  Edited := True;
                  W.Remove(E);
                  exit;
               end if;
            end loop;
            exit when not Edited;
         end;
      end loop;
   end CheckEntities;
   
   function InvalidEnt(E : not null access Entity'Class) return Boolean
   is
   begin
      if E.Coords.x < 0.0 or E.Coords.x > 240.0 then return True; end if;
      if E.Coords.y < 0.0 or E.Coords.y > 320.0 then return True; end if;
      return False;
   end InvalidEnt;
   
   function GetIntCoords(flCoords : Vec2D) return Point
   is
      retCoords : Vec2D;
   begin
      retCoords := flCoords;
      
      if retCoords.x < 0.0 or retCoords.x > 240.0 then
         retCoords.x := 120.0;
      end if;
      if retCoords.y < 0.0 or retCoords.y > 320.0 then
         retCoords.y := 160.0;
      end if;
      
      return Point'(Natural(retCoords.x), Natural(retCoords.y));
   end getIntCoords;

end Renderer;
