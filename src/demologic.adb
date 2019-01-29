with HAL.Touch_Panel; use HAL.Touch_Panel;
with STM32.Board; use STM32.Board;
with STM32.GPIO; use STM32.GPIO;
with STM32.User_Button; use STM32;
with L3GD20; use L3GD20;
with Circles;
with Rectangles;
with Vectors2D; use Vectors2D;
with HAL.Bitmap; use HAL.Bitmap;
with BMP_Fonts;

package body DemoLogic is
     
   Hold : Natural := 0;
   LastX, LastY : Integer := 0;
   GlobalGravity : Vec2D := (0.0, 9.81);
   MaxHold : constant Natural := 40;
   EntCreatorMat : Materials.Material := Materials.BALLOON;
   type Modes is (M_Frozen, M_Disabled, M_Circle, M_Rectangle);
   Mode : Modes := M_Disabled;
   CurWorld : World;

   function Inputs(W : in out World; Frozen : in out Boolean;
                   Cooldown : Integer; Cue : in out VisualCue) return Boolean
   is
      State : constant TP_State := Touch_Panel.Get_All_Touch_Points;
      Axes : L3GD20.Angle_Rates;
      Shaked : Boolean := False;
      PushVec : Vec2D := (0.0, 0.0);
      Threshold : constant Angle_Rate := 100;
      Multiplier : constant Float := 0.02;
   begin
      CurWorld := W;
      Get_Raw_Angle_Rates (Gyro, Axes);
      Cue := VisualCue'(0, 0, -1, EntCircle, EntCreatorMat);

      -- User button
      if User_Button.Has_Been_Pressed then
         Mode := Modes'Val((Modes'Pos(Mode) + 1) mod (Modes'Pos(Modes'Last) + 1));
         ModeActions(Frozen);
         if Mode = M_Frozen then
            ShowActionMenu;
            Mode := Modes'Val((Modes'Pos(Mode) + 1) mod (Modes'Pos(Modes'Last) + 1));
            ModeActions(Frozen);
         end if;
      end if;

      -- Entity creator
      if Cooldown = 0 then 
         if State'Length >= 1 then
            Hold := Natural'Min(Hold + 1, MaxHold);
            LastX := State(State'First).X;
            LastY := State(State'First).Y;
            if LastX > 0 and LastY > 0 and Hold > 0 then
               DisplayEntity(LastX, LastY, Hold, Cue);
            end if;
         elsif Hold > 0 then
            if LastX > 0 and LastY > 0 and Hold > 0 then
               CreateEntity(W, LastX, LastY, Hold);
            end if;
            Hold := 0;
            return True;
         end if;
      elsif State'Length >= 1 then
         Hold := Natural'Min(Hold + 1, MaxHold);
         LastX := State(State'First).X;
         LastY := State(State'First).Y;
         if LastX > 0 and LastY > 0 and Hold > 0 then
            DisplayEntity(LastX, LastY, Hold, Cue);
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
            declare
               use DoublyLinkedListEnts;
               Curs : Cursor := W.GetEntities.First;
               E : access Entity'Class;
            begin
               while Curs /= No_Element loop
                  E := Element(Curs);
                  E.all.ApplyForce(PushVec * E.Mass * Multiplier);
                  Curs := Next(Curs);
               end loop;
            end;
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
   
   procedure ShowActionMenu is
      ActionMenu : Menu;
   begin
      ActionMenu.Init(Black, White, BMP_Fonts.Font12x12, Menu_Static);
      ActionMenu.AddItem(GetGravityStr, (40, 200, 40, 80), ToggleGravity'Access);
      ActionMenu.AddItem(GetMatName(EntCreatorMat), GotoNextMat'Access);
      ActionMenu.Show;
      ActionMenu.Listen;
   end ShowActionMenu;
                         
   procedure ToggleGravity(This : in out Menu) is
      use DoublyLinkedListEnts;
      E : access Entity'Class;
      Curs : Cursor := CurWorld.Entities.First;
      Grav : constant Vec2D := (0.0, (if GlobalGravity.y = 0.0 then 9.81 else 0.0));
   begin
      GlobalGravity := Grav;
      This.ChangeText(0, GetGravityStr);
      while Curs /= No_Element loop
         E := Element(Curs);
         E.all.SetGravity(Grav);
         Curs := Next(Curs);
      end loop;
   end ToggleGravity;
   
   procedure CreateEntity(W : in out World; X, Y : Integer; H : Natural)
   is
   begin
      case Mode is
         when M_Circle => CreateCircle(W, X, Y, H);
         when M_Rectangle => CreateRectangle(W, X, Y, H);
         when M_Disabled => null;
         when M_Frozen => null;
      end case;  
   end CreateEntity;
   
   procedure DisplayEntity(X, Y : Integer; H : Natural; Cue : in out VisualCue)
   is
   begin
      case Mode is
         when M_Circle => Cue := VisualCue'(X, Y, H, EntCircle, EntCreatorMat);
         when M_Rectangle => Cue := VisualCue'(X, Y, H, EntRectangle, EntCreatorMat);
         when M_Disabled | M_Frozen => null;
      end case;
   end DisplayEntity;

   procedure CreateCircle(W : in out World; X, Y : Integer; H : Natural)
   is
      C : Circles.CircleAcc;
      VecZero : constant Vec2D := (0.0, 0.0);
      VecPos : constant Vec2D := (Float(X), Float(Y));
   begin
      C := Circles.Create(VecPos, VecZero, GlobalGravity, Float(H), EntCreatorMat);
      W.AddEntity(C);
   end CreateCircle;

   procedure CreateRectangle(W : in out World; X, Y : Integer; H : Natural)
   is
      R : Rectangles.RectangleAcc;
      VecZero : constant Vec2D := (0.0, 0.0);
      VecPos : constant Vec2D := (Float(X), Float(Y));
   begin
      R := Rectangles.Create(VecPos, VecZero, GlobalGravity, (Float(H), Float(H)) * 1.0, EntCreatorMat);
      W.AddEntity(R);
   end CreateRectangle;

   function GetMatName(This : Material) return String
   is
      StrMat : constant String := MaterialType'Image(This.MType);
   begin
      return StrMat(StrMat'First + 2 .. StrMat'Last);
   end GetMatName;
   
   function GetGravityStr return String
   is
   begin
      if GlobalGravity.y = 0.0 then
         return "GRAVITY OFF";
      end if;
      return "GRAVITY ON";
   end GetGravityStr;
   
   procedure GotoNextMat(This : in out Menu) is
   begin
      case EntCreatorMat.MType is
         when MTConcrete => EntCreatorMat := WOOD;
         when MTWood => EntCreatorMat := STEEL;
         when MTSteel => EntCreatorMat := RUBBER;
         when MTRubber => EntCreatorMat := ICE;
         when MTIce => EntCreatorMat := BALLOON;
         when MTBalloon => EntCreatorMat := STATIC;
         when MTStatic => EntCreatorMat := CONCRETE;
         when others => EntCreatorMat := RUBBER;
      end case;
      This.ChangeText(1, GetMatName(EntCreatorMat));
   end GotoNextMat;

end DemoLogic;

