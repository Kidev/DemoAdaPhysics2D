with HAL.Touch_Panel; use HAL.Touch_Panel;
with STM32.Board; use STM32.Board;
with Bitmapped_Drawing; use Bitmapped_Drawing;
with Ada.Unchecked_Deallocation;

package body Menus is

   procedure Init(This : in out Menu; Back, Fore : Bitmap_Color; Font : BMP_Font) is
   begin
      This.Items := new List;
      This.Background := (0, 0, 0, 0);
      This.BackgroundColor := Back;
      This.ForegroundColor := Fore;
      This.Font := Font;
   end Init;
   
   procedure AddItem(This : in out Menu; That : MenuItem) is
   begin
      if Integer(This.Items.Length) = 0 then
         This.Background.X1 := That.Pos.X1 - BorderSize;
         This.Background.Y1 := That.Pos.Y1 - BorderSize;
      end if;
      This.Items.Append(That);
      This.Background.X2 := That.Pos.X2 + BorderSize;
      This.Background.Y2 := That.Pos.Y2 + BorderSize;
   end AddItem;
   
   procedure AddItem(This : in out Menu; Text : Bounded_String; Action : MenuAction) is
      LastItem : constant MenuItem := This.Items.Last_Element;
      That : MenuItem := LastItem;
   begin
      That.Text := Text;
      That.Action := Action;
      That.Pos := (LastItem.Pos.X1, LastItem.Pos.X2,
                   LastItem.Pos.Y2 + BorderSize,
                   LastItem.Pos.Y2 + BorderSize + (LastItem.Pos.Y2 - LastItem.Pos.Y1));
      This.AddItem(That);
   end AddItem;

   procedure Show(This : in out Menu) is
      Curs : Cursor := This.Items.First;
      Item : MenuItem;
   begin
      
      DrawRect(This.Background, True, This.BackgroundColor);
      
      while Curs /= No_Element loop

         Item := Element(Curs);
         DrawRect(Item.Pos, False, This.ForegroundColor);
         DrawText(Item.Pos, Item.Text, This.Font, This.BackgroundColor, This.ForegroundColor);
         
         Curs := Next(Curs);

      end loop;
      
      Display.Update_Layer(1, Copy_Back => True);
      
   end Show;

   procedure Listen(This : in out Menu; Destroy : Boolean := True; WaitFor : Natural := WaitTicks)
   is
      Action : MenuAction := null;
      Tick : Natural := 0;
   begin
      loop
         declare
            State : constant TP_State := Touch_Panel.Get_All_Touch_Points;
            X, Y : Integer := 0;
            Curs : Cursor := This.Items.First;
            Item : MenuItem;
         begin
            if Tick > WaitFor and State'Length = 1 then
               X := State(State'First).X;
               Y := State(State'First).Y;

               while Curs /= No_Element loop
                  
                  Item := Element(Curs);
                  if X >= Item.Pos.X1 and then X <= Item.Pos.X2
                    and then Y >= Item.Pos.Y1 and then Y <= Item.Pos.Y2 then
                     
                     Action := Item.Action;
                     exit;
                     
                  end if;
                  Curs := Next(Curs);
                  
               end loop;
               
            end if;
         end;
         Tick := Tick + 1;
         exit when Action /= null;
      end loop;
      
      if Destroy then
         This.Free;
      end if;
      
      Action.all;
      
   end Listen;

   procedure Free(This : in out Menu) is
      procedure FreeList is new Ada.Unchecked_Deallocation(List, MenuListAcc);
   begin
      This.Items.Clear;
      FreeList(This.Items);
   end Free;
                                         
   procedure DrawRect(Item : MenuItemPos; Fill : Boolean; Color : Bitmap_Color) is
   begin
      Display.Hidden_Buffer(1).Set_Source(Color);
      if Fill then
         Display.Hidden_Buffer(1).Fill_Rect((Position => (Item.X1, Item.Y1),
                                             Height => Item.Y2 - Item.Y1,
                                             Width => Item.X2 - Item.X1));
      else
         Display.Hidden_Buffer(1).Draw_Rect((Position => (Item.X1, Item.Y1),
                                             Height => Item.Y2 - Item.Y1,
                                             Width => Item.X2 - Item.X1));         
      end if;
   end DrawRect;
   
   procedure DrawText(Item : MenuItemPos; Text : Bounded_String; Font : BMP_Font; Back, Fore : Bitmap_Color) is
   begin
      Draw_String(Buffer => Display.Hidden_Buffer(1).all,
                  Start => (Item.X1 + BorderSize, Item.Y1 + BorderSize),
                  Msg => To_String(Text),
                  Font => Font,
                  Foreground => Fore,
                  Background => Back);
   end DrawText;

end Menus;
