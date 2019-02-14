with STM32.RNG.Interrupts; use STM32.RNG.Interrupts;
with STM32.Board; use STM32.Board;
with HAL; use HAL;

package body Utils is

   procedure Clear(Update : Boolean; Color : Bitmap_Color := BG) is
   begin
      Display.Hidden_Buffer(1).Set_Source(Color);
      Display.Hidden_Buffer(1).Fill;
      if Update then
         Display.Update_Layer(1, Copy_Back => False);
      end if;
   end Clear;

   function GetRandomFloat return Float is
   begin
      return Float(Random) / Float(UInt32'Last);
   end GetRandomFloat;

end Utils;
