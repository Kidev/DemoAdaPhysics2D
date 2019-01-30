with HAL.Touch_Panel; use HAL.Touch_Panel;
with STM32.Board; use STM32.Board;
with Bitmapped_Drawing; use Bitmapped_Drawing;
with STM32.User_Button; use STM32;
with Ada.Unchecked_Deallocation;
with Ada.Strings;

package body Menus is
   
-- Contracts ghosts
   function StoreAndReturnLen(Len : Integer) return Integer is
   begin
      StoredLen := Len;
      return Len;
   end StoreAndReturnLen;
   
   function CheckOverflow(Pos : MenuItemPos) return Boolean is
   begin
      return Pos.Y2 + BorderSize <= 320 - (Pos.Y2 - Pos.Y1) - BorderSize;
   end CheckOverflow;
   
   function GetItemStr(This : Menu; Index : Natural) return String is
      use MenuItemsList;
      Curs : MenuItemsList.Cursor := This.Items.First;
      Count : Natural := 0;
   begin
      while Curs /= MenuItemsList.No_Element loop
         if Count = Index then
            return To_String(MenuItemsList.Element(Curs).Text);
         end if;
         Count := Count + 1;
         Curs := MenuItemsList.Next(Curs);
      end loop;
      return "";
   end GetItemStr;

-- Actual package
   procedure Init(This : in out Menu; Back, Fore : Bitmap_Color; Font : BMP_Font; MenuType : MenuTypes := Menu_Default) is
   begin
      This.Items := new MenuItemsList.List;
      This.Background := (0, 0, 0, 0);
      This.BackgroundColor := Back;
      This.ForegroundColor := Fore;
      This.Font := Font;
      This.MenuType := MenuType;
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
   
   procedure AddItem(This : in out Menu; Text : String; Pos : MenuItemPos; Action : MenuAction) is
      That : MenuItem;
   begin
      That.Text := To_Bounded_String(Text, Drop => Ada.Strings.Right);
      That.Pos := Pos;
      That.Action := Action;
      This.AddItem(That);
   end AddItem;
   
   procedure AddItem(This : in out Menu; Text : String; Action : MenuAction)
   is
      LastItem : constant MenuItem := This.Items.Last_Element;
      That : MenuItem := LastItem;
   begin
      That.Text := To_Bounded_String(Text, Drop => Ada.Strings.Right);
      That.Action := Action;
      That.Pos := (LastItem.Pos.X1, LastItem.Pos.X2,
                   LastItem.Pos.Y2 + BorderSize,
                   LastItem.Pos.Y2 + BorderSize + (LastItem.Pos.Y2 - LastItem.Pos.Y1));
      This.AddItem(That);
   end AddItem;

   procedure Show(This : in out Menu) is
      use MenuItemsList;
      Curs : MenuItemsList.Cursor := This.Items.First;
      Item : MenuItem;
   begin
      
      DrawRect(This.Background, True, This.BackgroundColor);
      
      while Curs /= MenuItemsList.No_Element loop

         Item := MenuItemsList.Element(Curs);
         DrawRect(Item.Pos, False, This.ForegroundColor);
         DrawText(Item.Pos, Item.Text, This.Font, This.BackgroundColor, This.ForegroundColor);
         
         Curs := MenuItemsList.Next(Curs);

      end loop;
      
      Display.Update_Layer(1, Copy_Back => True);
      Display.Update_Layer(1, Copy_Back => True);
      
   end Show;

   procedure Listen(This : in out Menu; Destroy : Boolean := True; WaitFor : Natural := WaitTicks)
   is
      Action : MenuAction := null;
      Tick : Natural := 0;
   begin
      loop
         Action := null;
         Tick := 0;
         loop
            declare
               use MenuItemsList;
               State : constant TP_State := Touch_Panel.Get_All_Touch_Points;
               X, Y : Integer := 0;
               Curs : MenuItemsList.Cursor := This.Items.First;
               Item : MenuItem;
            begin
               if This.MenuType = Menu_Static and then User_Button.Has_Been_Pressed then
                  if Destroy then
                     This.Free;
                  end if;
                  return;
               end if;
               if Tick > WaitFor and State'Length = 1 then
                  X := State(State'First).X;
                  Y := State(State'First).Y;

                  while Curs /= MenuItemsList.No_Element loop
                  
                     Item := MenuItemsList.Element(Curs);
                     if X >= Item.Pos.X1 and then X <= Item.Pos.X2
                       and then Y >= Item.Pos.Y1 and then Y <= Item.Pos.Y2 then
                     
                        Action := Item.Action;
                        exit;
                     
                     end if;
                     Curs := MenuItemsList.Next(Curs);
                  
                  end loop;
               
               end if;
            end;
            Tick := Tick + 1;
            exit when Action /= null;
         end loop;

         if Action /= null then
            Action.all(This);
         
            if This.MenuType = Menu_Static then
               This.Show;
            end if;
         end if;
         
         exit when This.MenuType /= Menu_Static;

      end loop;
      
   end Listen;

   procedure Free(This : in out Menu) is
      procedure FreeList is new Ada.Unchecked_Deallocation(MenuItemsList.List, MenuListAcc);
   begin
      This.Items.Clear;
      FreeList(This.Items);
      This.Items := null;
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
   
   procedure ChangeText(This : in out Menu; Index : Natural; Text : String) is
      use MenuItemsList;
      Curs : MenuItemsList.Cursor := This.Items.First;
      Count : Natural := 0;
      Item : MenuItem;
   begin
      while Curs /= MenuItemsList.No_Element loop
         if Count = Index then
            Item := MenuItemsList.Element(Curs);
            Item.Text := To_Bounded_String(Text, Drop => Ada.Strings.Right);
            This.Items.Replace_Element(Curs, Item);
            exit;
         end if;
         Count := Count + 1;
         Curs := MenuItemsList.Next(Curs);
      end loop;
   end ChangeText;

end Menus;
