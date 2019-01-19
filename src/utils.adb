with STM32.Board; use STM32.Board;

package body Utils is

   procedure Clear(Update : Boolean) is
   begin
      Display.Hidden_Buffer(1).Set_Source(BG);
      Display.Hidden_Buffer(1).Fill;
      if Update then
         Display.Update_Layer(1, Copy_Back => False);
      end if;
   end Clear;

end Utils;
