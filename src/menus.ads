with HAL.Bitmap; use HAL.Bitmap;
with Ada.Containers.Doubly_Linked_Lists;
with BMP_Fonts; use BMP_Fonts;
with Ada.Strings.Bounded;

package Menus is

   -- Tick freeze when menu is displayed, to prevent mistouches
   WaitTicks : constant Natural := 100;
   BorderSize : constant Natural := 10;
   MaxStrLen : constant Natural := 12;
   
   package BoundedStr is new Ada.Strings.Bounded.Generic_Bounded_Length(MaxStrLen);
   use BoundedStr;
   
   type MenuAction is access procedure;
   
   -- Holds the position of a menu item
   type MenuItemPos is record
      X1, X2, Y1, Y2 : Natural;
   end record;
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
      Items : MenuListAcc;
      Background : MenuItemPos;
      BackgroundColor : Bitmap_Color;
      ForegroundColor : Bitmap_Color;
      Font : BMP_Font;
   end record;
   pragma Pack(Menu);
   
   -- Init a menu
   procedure Init(This : in out Menu; Back, Fore : Bitmap_Color; Font : BMP_Font);

   -- Add item to menu
   procedure AddItem(This : in out Menu; That : MenuItem);
   
   -- Same, but more flexible
   procedure AddItem(This : in out Menu; Text : String; Pos : MenuItemPos; Action : MenuAction);
   
   -- Add item to menu, copying the first item
   procedure AddItem(This : in out Menu; Text : String; Action : MenuAction)
     with Pre => Integer(This.Items.Length) >= 1;

   -- Displays the menu
   procedure Show(This : in out Menu);

   -- Wait for user choice
   procedure Listen(This : in out Menu; Destroy : Boolean := True; WaitFor : Natural := WaitTicks);

   -- Cleans the menu
   procedure Free(This : in out Menu);
   
private
   
   procedure DrawRect(Item : MenuItemPos; Fill : Boolean; Color : Bitmap_Color); 
   
   procedure DrawText(Item : MenuItemPos; Text : Bounded_String; Font : BMP_Font; Back, Fore : Bitmap_Color);

end Menus;
