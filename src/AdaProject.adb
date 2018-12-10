------------------------------------------------------------------------------
--                                                                          --
--                        Copyright (C) 2018, Kidev                         --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);
--  The "last chance handler" is the user-defined routine that is called when
--  an exception is propagated. We need it in the executable, therefore it
--  must be somewhere in the closure of the context clauses.

with STM32.Board; use STM32.Board;
with HAL.Bitmap; use HAL.Bitmap;
with STM32.User_Button; use STM32;
with BMP_Fonts;
with LCD_Std_Out;

with Rectangles;
with Circles;
with Worlds;
with Materials;
with Vectors2D; use Vectors2D;
with Renderer; use Renderer;
with GameLogic; use GameLogic;

procedure AdaProject is

   BG : constant Bitmap_Color := (Alpha => 255, others => 0);
   procedure Init;
   procedure Clear(Update : Boolean);

   procedure Init is
   begin
      Display.Initialize;
      Display.Initialize_Layer(1, RGB_565);
      Touch_Panel.Initialize;
      User_Button.Initialize;
      LCD_Std_Out.Set_Font(BMP_Fonts.Font12x12);
      LCD_Std_Out.Current_Background_Color := BG;
      Clear(True);
   end Init;

   procedure Clear(Update : Boolean) is
   begin
      Display.Hidden_Buffer(1).Set_Source(BG);
      Display.Hidden_Buffer(1).Fill;
      LCD_Std_Out.Clear_Screen;
      if Update then
         Display.Update_Layer(1, Copy_Back => False);
      end if;
   end Clear;

   C1, C2, C3, C4 : Circles.CircleAcc;
   R0, R1, R2, R3 : Rectangles.RectangleAcc;
   W1 : Worlds.World;
   VecZero, LatSpeed : Vec2D;
   Vec1, Vec2, Grav : Vec2D;

   fps : constant Float := 24.0;
   dt : constant Float := 1.0 / fps;
   cd : constant Integer := 10; -- * dt

   -- if true, the world will no longer update (blue button)
   Frozen : Boolean := True;
   Cooldown : Integer := 0;
   Tick : Integer := 0;

begin
   VecZero := Vec2D'(x => 0.0, y => 0.0);
   LatSpeed := Vec2D'(x => 50.0, y => 0.0);
   Vec1 := Vec2D'(x => 20.0, y => 10.0);
   Vec2 := Vec2D'(x => 50.0, y => 10.0);
   Grav := Vec2D'(x => 0.0, y => 9.81);

   C1 := Circles.Create(Vec1, LatSpeed, Grav, 5.0, Materials.RUBBER);
   C2 := Circles.Create(Vec2, VecZero, Grav, 2.0, Materials.RUBBER);
   C3 := Circles.Create(Vec1 + Vec2, -LatSpeed, Grav, 15.0, Materials.RUBBER);
   C4 := Circles.Create(2.0 * Vec2 - Vec1, VecZero, Grav, 6.0, Materials.RUBBER);

   -- Ceiling
   Vec1 := Vec2D'(x => 5.0, y => 0.0);
   Vec2 := Vec2D'(x => 230.0, y => 5.0);
   R0 := Rectangles.Create(Vec1, VecZero, VecZero, Vec2, Materials.STATIC);

   -- Floor
   Vec1 := Vec2D'(x => 0.0, y => 300.0);
   Vec2 := Vec2D'(x => 240.0, y => 20.0);
   R1 := Rectangles.Create(Vec1, VecZero, VecZero, Vec2, Materials.STATIC);

   -- Right wall
   Vec1 := Vec2D'(x => 235.0, y => 0.0);
   Vec2 := Vec2D'(x => 5.0, y => 300.0);
   R2 := Rectangles.Create(Vec1, VecZero, VecZero, Vec2, Materials.STATIC);

   -- Left wall
   Vec1 := Vec2D'(x => 0.0, y => 0.0);
   Vec2 := Vec2D'(x => 5.0, y => 300.0);
   R3 := Rectangles.Create(Vec1, VecZero, VecZero, Vec2, Materials.STATIC);

   W1.Init(dt);

   W1.Add(R0);
   W1.Add(R1);
   W1.Add(R2);
   W1.Add(R3);

   W1.Add(C1);
   W1.Add(C2);
   W1.Add(C3);
   W1.Add(C4);

   for I in 1 .. 60 loop
      C1 := Circles.Create((Float(I) * 4.0 + 10.0, Float(I) * 4.0 + 10.0), VecZero, Grav, 2.0, Materials.RUBBER);
      W1.Add(C1);
   end loop;

   Init;
   loop
      if Inputs(W1, Frozen, Cooldown) then -- gets the user inputs and updates the world accordingly
         Cooldown := cd; -- reset cooldown
      end if;
      if not Frozen then
         Tick := Tick + 1;
         W1.Step; -- update the world for one tick (dt)
      end if;
      CheckEntities(W1); -- check if entities are valid (prevents card crash)
      Render(W1.GetEntities); -- renders
      Clear(False); -- clear buffer for next render
      if Cooldown > 0 then
         Cooldown := Cooldown - 1;
      end if;
   end loop;

end AdaProject;
