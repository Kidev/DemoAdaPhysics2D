with HAL.Touch_Panel; use HAL.Touch_Panel;
with HAL.Bitmap; use HAL.Bitmap;
with STM32.Board; use STM32.Board;
with AdaPhysics2DDemo;
with STM32.User_Button; use STM32;
with BMP_Fonts;
with LCD_Std_Out;
with Utils;

package body MainMenu is

   procedure ShowMainMenu is
      StartMenu : Menu;
   begin

      Utils.Clear(False);

      StartMenu.Init(Black, White, BMP_Fonts.Font16x24, Menu_Default);
      StartMenu.AddItem(Text => "START",
                        Pos => (20, 220, 20, 120),
                        Action => AdaPhysics2DDemo.Start'Access);
      StartMenu.AddItem(Text => "HELP",
                        Action => ShowHelpScreen'Access);
      StartMenu.Show;
      StartMenu.Listen;

   end ShowMainMenu;

   procedure ShowHelpScreen(This : in out Menu) is
      Tick : Natural := 0;
   begin
      This.Free;

      Utils.Clear(True);
      Utils.Clear(True);

      LCD_Std_Out.Clear_Screen;
      LCD_Std_Out.Put_Line("Demo of AdaPhysics2D by Kidev");
      LCD_Std_Out.New_Line;
      LCD_Std_Out.New_Line;
      LCD_Std_Out.Put_Line("Blue button to change mode:");
      LCD_Std_Out.Put_Line("- Touch screen is off");
      LCD_Std_Out.Put_Line("- Touch to create a circle");
      LCD_Std_Out.Put_Line("- Touch to create a rectangle");
      LCD_Std_Out.Put_Line("- Touch to change materials");
      LCD_Std_Out.Put_Line("  Also freezes the physics");
      LCD_Std_Out.New_Line;
      LCD_Std_Out.Put_Line("Try to shake the board !");
      LCD_Std_Out.New_Line;
      LCD_Std_Out.New_Line;
      LCD_Std_Out.Put_Line("TOUCH TO GO BACK TO MENU");

      loop
         declare
            State : constant TP_State := Touch_Panel.Get_All_Touch_Points;
         begin
            exit when Tick > Menus.WaitTicks and (State'Length >= 1 or User_Button.Has_Been_Pressed);
         end;
         Tick := Tick + 1;
      end loop;

      ShowMainMenu;

   end ShowHelpScreen;

end MainMenu;
