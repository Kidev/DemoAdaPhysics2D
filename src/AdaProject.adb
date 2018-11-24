------------------------------------------------------------------------------
--                                                                          --
--                     Copyright (C) 2018, Kidev & Azu                      --
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
--with HAL.Framebuffer; use HAL.Framebuffer;
--with Ada.Real_Time; use Ada.Real_Time;
--with HAL.Touch_Panel;       use HAL.Touch_Panel;
--with STM32.User_Button;     use STM32;
with BMP_Fonts;
with LCD_Std_Out;

with Rectangles;
with Circles;
with Worlds;
with Vectors2D; use Vectors2D;
with Renderer; use Renderer;

procedure AdaProject is

   BG : constant Bitmap_Color := (Alpha => 255, others => 0);
   procedure Init;
   procedure Clear(Update : Boolean);

   procedure Init is
   begin
      Display.Initialize;
      Display.Initialize_Layer(1, ARGB_8888);
      --LCD_Std_Out.Set_Orientation(Landscape);
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

   Count : Integer := 0;
   --Period : constant Time_Span := Milliseconds(1000);
   --NextTick : Time := Clock;

   C1, C2 : Circles.CircleAcc;
   R1, R2 : Rectangles.RectangleAcc;
   W1 : Worlds.World;
   VecZero, LatSpeed : Vec2D;
   Vec1, Vec2, Grav : Vec2D;

   fps : constant Float := 26.0;
   dt : constant Float := 1.0 / fps;

begin
   VecZero := Vec2D'(x => 0.0, y => 0.0);
   LatSpeed := Vec2D'(x => 50.0, y => 0.0);
   Vec1 := Vec2D'(x => 20.0, y => 10.0);
   Vec2 := Vec2D'(x => 50.0, y => 10.0);
   Grav := Vec2D'(x => 0.0, y => 9.81);

   W1.Init(dt);

   C1 := Circles.Create(Vec1, LatSpeed, Grav, 10.0, 0.9, 5.0);
   C2 := Circles.Create(Vec2, VecZero, Grav, 5.0, 0.9, 2.0);

   Vec1 := Vec2D'(x => 0.0, y => 300.0);
   Vec2 := Vec2D'(x => 240.0, y => 20.0);

   R1 := Rectangles.Create(Vec1, VecZero, VecZero, Vec2, 0.0, 1.0);

   Vec1 := Vec2D'(x => 100.0, y => 20.0);
   Vec2 := Vec2D'(x => 30.0, y => 20.0);

   R2 := Rectangles.Create(Vec1, VecZero, Grav, Vec2, 20.0, 0.1);

   W1.Add(C1);
   W1.Add(C2);
   W1.Add(R1);
   W1.Add(R2);

   Init;
   loop
      Clear(False);

      W1.Step;
      Render(W1.GetEntities);

      Count := Count + 1;
      -- NextTick := NextTick + Period;
      -- delay until NextTick;
   end loop;

end AdaProject;
