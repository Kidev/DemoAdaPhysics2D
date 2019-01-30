with HAL.Bitmap; use HAL.Bitmap;
with Ada.Containers.Doubly_Linked_Lists;
with BMP_Fonts; use BMP_Fonts;
with Ada.Strings.Bounded;

package Menus is

-- Actual package

   -- Tick freeze when menu is displayed, to prevent mistouches
   WaitTicks : constant Natural := 100;
   BorderSize : constant Natural := 10;
   MaxStrLen : constant Natural := 12;
   
   package BoundedStr is new Ada.Strings.Bounded.Generic_Bounded_Length(MaxStrLen);
   use BoundedStr;
   
   type Menu;
   type MenuAction is access procedure(This : in out Menu);
   
   type MenuTypes is (Menu_Default, Menu_Static);

   -- Holds the position of a menu item
   type MenuItemPos is record
      X1, X2, Y1, Y2 : Natural := 0;
   end record
     with 
       Dynamic_Predicate => MenuItemPos.X2 <= 240
                        and MenuItemPos.Y2 <= 320;
   pragma Pack(MenuItemPos);

   -- Holds data about a menu item
   type MenuItem is record
      Text : Bounded_String;
      Pos : MenuItemPos;
      Action : MenuAction;
   end record;
   pragma Pack(MenuItem);

   -- Holds the menu items
   package DoublyLinkedListMenuItems is new Ada.Containers.Doubly_Linked_Lists(MenuItem);
   use DoublyLinkedListMenuItems;
   type MenuListAcc is access List;

   -- Hold all the menu data required, tagged for the lovely dot notation
   type Menu is tagged record
      Items : MenuListAcc := null;
      Background : MenuItemPos;
      BackgroundColor : Bitmap_Color;
      ForegroundColor : Bitmap_Color;
      Font : BMP_Font;
      MenuType : MenuTypes;
   end record;
   pragma Pack(Menu);

-- Contracts ghosts

   StoredLen : Integer := 0 with Ghost;
   StoredLastPos : MenuItemPos with Ghost;
   
   function StoreAndReturnLen(Len : Integer) return Integer with Ghost;
   function CheckOverflow(Pos : MenuItemPos) return Boolean with Ghost;
   function GetItemStr(This : Menu; Index : Natural) return String with Ghost;
   
-- Menu Primitives

   -- Init a menu
   procedure Init(This : in out Menu; Back, Fore : Bitmap_Color; Font : BMP_Font; MenuType : MenuTypes := Menu_Default)
     with
       Post => This.Items /= null;

   -- Add item to menu
   procedure AddItem(This : in out Menu; That : MenuItem)
     with
       Pre => This.Items /= null
          and StoreAndReturnLen(Integer(This.Items.Length)) >= 0
          and That.Action /= null,
       Post => This.Items /= null
           and StoredLen + 1 = Integer(This.Items.Length)
           and This.Items.Last_Element.Pos = That.Pos
           and This.Items.Last_Element.Action = That.Action
           and This.Items.Last_Element.Text = That.Text;
   
   -- Same, but more flexible
   procedure AddItem(This : in out Menu; Text : String; Pos : MenuItemPos; Action : MenuAction)
     with
       Pre => This.Items /= null
          and StoreAndReturnLen(Integer(This.Items.Length)) >= 0
          and Action /= null,
       Post => This.Items /= null
           and StoredLen + 1 = Integer(This.Items.Length)
           and This.Items.Last_Element.Pos = Pos
           and This.Items.Last_Element.Action = Action
           and This.Items.Last_Element.Text = Text;

   -- Add item to menu, copying the first item
   procedure AddItem(This : in out Menu; Text : String; Action : MenuAction)
     with
       Global => (Proof_In => (StoredLen),
                  Input => (BorderSize, MaxStrLen)),
       Pre => This.Items /= null
          and StoreAndReturnLen(Integer(This.Items.Length)) >= 1
          and CheckOverflow(This.Items.Last_Element.Pos)
          and Action /= null,
       Post => This.Items /= null
           and StoredLen + 1 = Integer(This.Items.Length)
           and This.Items.Last_Element.Action = Action
           and This.Items.Last_Element.Text = Text,
       Depends => (This => +(Text, Action, BorderSize, MaxStrLen));

   -- Displays the menu
   procedure Show(This : in out Menu)
     with
       Pre => This.Items /= null;

   -- Wait for user choice
   -- Will call the relevant MenuAction with a parameter : This (the menu)
   -- It MUST be freed manually in case of a Menu_Default
   -- It is freed automatically for a Menu_Static with Desroy = True
   procedure Listen(This : in out Menu; Destroy : Boolean := True; WaitFor : Natural := WaitTicks);

   -- Cleans the menu
   procedure Free(This : in out Menu)
     with
       Pre => This.Items /= null,
       Post => This.Items = null;
   
   -- Update the text of the Index'th menu item (in order at the creation)
   procedure ChangeText(This : in out Menu; Index : Natural; Text : String)
     with
       Pre => This.Items /= null
          and Index < Integer(This.Items.Length),
       Post => GetItemStr(This, Index) = Text,
       Depends => (This => +(Index, Text));

private
   
   procedure DrawRect(Item : MenuItemPos; Fill : Boolean; Color : Bitmap_Color); 
   
   procedure DrawText(Item : MenuItemPos; Text : Bounded_String; Font : BMP_Font; Back, Fore : Bitmap_Color);

end Menus;
