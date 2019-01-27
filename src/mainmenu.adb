with HAL.Touch_Panel; use HAL.Touch_Panel;
with HAL.Bitmap; use HAL.Bitmap;
with STM32.Board; use STM32.Board;
with Bitmapped_Drawing; use Bitmapped_Drawing;
with AdaPhysics2DDemo;
with Utils;
with BMP_Fonts;

package body MainMenu is

   procedure ShowMenu
   is
      Action : access procedure := null;
   begin
      Utils.Clear(False);

      DrawMenu;

      loop
         declare
            State : constant TP_State := Touch_Panel.Get_All_Touch_Points;
            X, Y : Integer := 0;
         begin
            if State'Length = 1 then
               X := State(State'First).X;
               Y := State(State'First).Y;

               if X >= 20 and X <= 220 and Y >= 20 and Y <= 120 then
                  Action := AdaPhysics2DDemo.Start'Access;
               elsif X >= 20 and X <= 220 and Y >= 140 and Y <= 240 then
                  Action := null;
               end if;
            end if;
         end;
         exit when Action /= null;
      end loop;

      Action.all;
   end ShowMenu;

   procedure DrawMenu is
   begin

      Display.Hidden_Buffer(1).Set_Source(White);
      Display.Hidden_Buffer(1).Draw_Rect(Area => (Position => (20, 20),
                                                  Height => 100,
                                                  Width => 200));
      Display.Hidden_Buffer(1).Draw_Rect(Area => (Position => (20, 140),
                                                  Height => 100,
                                                  Width => 200));

      Draw_String(Buffer => Display.Hidden_Buffer(1).all,
                  Start => (40, 40),
                  Msg => "START",
                  Font => BMP_Fonts.Font16x24,
                  Foreground => White,
                  Background => Black);
      Draw_String(Buffer => Display.Hidden_Buffer(1).all,
                  Start => (40, 160),
                  Msg => "HELP",
                  Font => BMP_Fonts.Font16x24,
                  Foreground => White,
                  Background => Black);
      Draw_String(Buffer => Display.Hidden_Buffer(1).all,
                  Start => (5, 300),
                  Msg => "Demo of Kidev's AdaPhysics2D",
                  Font => BMP_Fonts.Font8x8,
                  Foreground => White,
                  Background => Black);

      Display.Update_Layer(1, Copy_Back => False);

   end DrawMenu;

end MainMenu;
