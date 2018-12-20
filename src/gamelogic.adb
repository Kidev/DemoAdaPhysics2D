with HAL.Touch_Panel; use HAL.Touch_Panel;
with HAL.Bitmap; use HAL.Bitmap;
with STM32.Board; use STM32.Board;
with STM32.GPIO; use STM32.GPIO;
with STM32.User_Button; use STM32;
with L3GD20; use L3GD20;
with Circles;
with Rectangles;
with Vectors2D; use Vectors2D;
with Materials;

package body GameLogic is
     
   Hold : Natural := 0;
   LastX, LastY : Integer := 0;
   GlobalGravity : constant Vec2D := (0.0, 0.0);
   type Modes is (M_Frozen, M_Disabled, M_Circle, M_Rectangle);
   Mode : Modes := M_Disabled;

   function Inputs(W : in out World; Frozen : in out Boolean; Cooldown : Integer) return Boolean
   is
      State : constant TP_State := Touch_Panel.Get_All_Touch_Points;
      Axes : L3GD20.Angle_Rates;
      Shaked : Boolean := False;
      PushVec : Vec2D := (0.0, 0.0);
      Threshold : constant Angle_Rate := 100;
      Multiplier : constant Float := 1.0;
   begin
      Get_Raw_Angle_Rates (Gyro, Axes);

      -- User button
      if User_Button.Has_Been_Pressed then
         Mode := Modes'Val((Modes'Pos(Mode) + 1) mod (Modes'Pos(Modes'Last) + 1));
         ModeActions(Frozen);
      end if;

      -- Entity creator
      if Cooldown = 0 then 
         if State'Length = 1 then
            Hold := Integer'Min(Hold + 1, 20);
            LastX := State(State'First).X;
            LastY := State(State'First).Y;
            if LastX > 0 and LastY > 0 and Hold > 0 then
               DisplayEntity(LastX, LastY, Hold);
            end if;
         elsif Hold > 0 then
            if LastX > 0 and LastY > 0 and Hold > 0 then
               CreateEntity(W, LastX, LastY, Hold);
            end if;
            Hold := 0;
            return True;
         end if;
      elsif State'Length = 1 then
         Hold := Integer'Min(Hold + 1, 20);
         LastX := State(State'First).X;
         LastY := State(State'First).Y;
         if LastX > 0 and LastY > 0 and Hold > 0 then
            DisplayEntity(LastX, LastY, Hold);
         end if;
      end if;
      
      -- Gyro
      if Cooldown = 0 then
         PushVec := (0.0, 0.0);
         if abs Axes.X >= Threshold then
            Shaked := True;
            PushVec.y := PushVec.y + Float(Axes.X);
         end if;
         if abs Axes.Y >= Threshold then
            Shaked := True;
            PushVec.x := PushVec.x + Float(Axes.Y);
         end if;
         if Shaked then
            for E of W.GetEntities loop
               E.all.ApplyForce(PushVec * Multiplier);
            end loop;
            return True;
         end if;
      end if;

      return False;
   end Inputs;
   
   procedure ModeActions(Frozen : in out Boolean)
   is
   begin
      if Mode = M_Frozen then
         Frozen := True;
         Turn_On(Red_LED);
         Turn_Off(Green_LED);
      else
         Frozen := False;
         Turn_Off(Red_LED);
      end if;
      if Mode = M_Disabled then
         Turn_Off(Green_LED);
      elsif Mode /= M_Frozen then
         Turn_On(Green_LED);
      end if;
   end ModeActions;
   
   procedure CreateEntity(W : in out World; X, Y, Hold : Integer)
   is
   begin
      case Mode is
         when M_Circle => CreateCircle(W, X, Y, Hold);
         when M_Rectangle => CreateRectangle(W, X, Y, Hold);
         when M_Disabled | M_Frozen => null; -- TODO create push from touch ?
      end case;  
   end CreateEntity;
   
   procedure DisplayEntity(X, Y, Hold : Integer)
   is
   begin
      case Mode is
         when M_Circle => DisplayCircle(X, Y, Hold);
         when M_Rectangle => DisplayRectangle(X, Y, Hold);
         when M_Disabled | M_Frozen => null;
      end case;  
   end DisplayEntity;
   
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
   
   procedure DisplayRectangle(X, Y, Hold : Integer)
   is
   begin
      Display.Hidden_Buffer(1).Set_Source(Red);
      Display.Hidden_Buffer(1).Draw_Rect
                       (
                        Area => (Position => (X - Hold, Y - Hold),
                                 Height => Hold * 2,
                                 Width => Hold * 2)
                       ); 
   end DisplayRectangle;

   procedure CreateRectangle(W : in out World; X, Y, Hold : Integer)
   is
      R : Rectangles.RectangleAcc;
      VecZero : constant Vec2D := (0.0, 0.0);
      VecPos : constant Vec2D := (Float(X) - Float(Hold), Float(Y) - Float(Hold));
   begin
      R := Rectangles.Create(VecPos, VecZero, GlobalGravity, (Float(Hold), Float(Hold)) * 2.0, Materials.RUBBER);
      W.Add(R);
   end CreateRectangle;

end GameLogic;

