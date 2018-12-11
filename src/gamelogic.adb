with HAL.Touch_Panel; use HAL.Touch_Panel;
with HAL.Bitmap; use HAL.Bitmap;
with STM32.Board; use STM32.Board;
with STM32.User_Button; use STM32;
with Circles;
with Vectors2D; use Vectors2D;
with Materials;

package body GameLogic is
     
   Hold : Integer := 0;
   LastX, LastY : Integer := 0;
   GlobalGravity : constant Vec2D := (0.0, 9.81);

   function Inputs(W : in out World; Frozen : in out Boolean; Cooldown : Integer) return Boolean
   is
      State : constant TP_State := Touch_Panel.Get_All_Touch_Points;
   begin
      -- Pause button
      if User_Button.Has_Been_Pressed then
         Frozen := not Frozen;
      end if;

      -- Entity creator
      if Cooldown = 0 then 
         if State'Length = 1 then
            Hold := Integer'Min(Hold + 1, 20);
            LastX := State(State'First).X;
            LastY := State(State'First).Y;
            DisplayCircle(LastX, LastY, Hold);
         elsif Hold > 0 then
            CreateCircle(W, LastX, LastY, Hold);
            Hold := 0;
            return True;
         end if;
      elsif State'Length = 1 then
         Hold := Integer'Min(Hold + 1, 20);
         DisplayCircle(State(State'First).X, State(State'First).Y, Hold);
      end if;

      return False;
   end Inputs;
   
   procedure DisplayCircle(X, Y, Hold : Integer)
   is
   begin
      Display.Hidden_Buffer(1).Set_Source(Red);
      Display.Hidden_Buffer(1).Draw_Circle
                    (
                     Center => (X, Y),
                     Radius => (Hold * 2)
                    );
   end DisplayCircle;
   
   procedure CreateCircle(W : in out World; X, Y, Hold : Integer)
   is
      C : Circles.CircleAcc;
      VecZero : constant Vec2D := (0.0, 0.0);
      VecPos : constant Vec2D := (Float(X), Float(Y));
   begin
      C := Circles.Create(VecPos, VecZero, GlobalGravity, Float(Hold) * 2.0, Materials.RUBBER);
      W.Add(C);
   end CreateCircle;

end GameLogic;

