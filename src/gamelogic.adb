with HAL.Touch_Panel; use HAL.Touch_Panel;
with STM32.Board; use STM32.Board;
with Entities; use Entities;

package body GameLogic is

   procedure Inputs(W : in out World)
   is
      State : constant TP_State := Touch_Panel.Get_All_Touch_Points;
      NewGrav : Vec2D;
   begin
      if State'Length = 1 then
         NewGrav := GetVecFromCenter(State(State'First).X, State (State'First).Y);
         for E of W.GetEntities loop
            E.SetGrav(NewGrav);
         end loop;
      end if;
   end Inputs;
   
   function GetVecFromCenter(X, Y : Integer) return Vec2D
   is
      xCenter : constant Integer := 120;
      yCenter : constant Integer := 160;
   begin
      return Vec2D'(
                    Clamp(Float(X - xCenter), -9.81, 9.81),
                    Clamp(Float(Y - yCenter), -9.81, 9.81)
                   );
   end GetVecFromCenter;
   
   function Clamp(Value, Min, Max : Float) return Float
   is
   begin

      if Value < Min then return Min; end if;
      if Value > Max then return Max; end if;
      return Value;

   end Clamp;

end GameLogic;
