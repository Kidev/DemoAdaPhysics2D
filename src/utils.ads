with HAL.Bitmap; use HAL.Bitmap;

package Utils is

   BG : constant Bitmap_Color := (Alpha => 255, others => 0);

   procedure Clear(Update : Boolean; Color : Bitmap_Color := BG);

   function GetRandomFloat return Float;

end Utils;
