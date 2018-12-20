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
with STM32.Device; use STM32.Device;
with STM32.GPIO; use STM32.GPIO;
with STM32.EXTI; use STM32.EXTI;
with STM32; use STM32;
with L3GD20; use L3GD20;
with HAL.Bitmap; use HAL.Bitmap;
with STM32.User_Button; use STM32;

with Rectangles;
with Worlds;
with Materials;
with Vectors2D; use Vectors2D;
with Renderer; use Renderer;
with GameLogic; use GameLogic;

procedure AdaProject is

   BG : constant Bitmap_Color := (Alpha => 255, others => 0);

   procedure Clear(Update : Boolean) is
   begin
      Display.Hidden_Buffer(1).Set_Source(BG);
      Display.Hidden_Buffer(1).Fill;
      if Update then
         Display.Update_Layer(1, Copy_Back => False);
      end if;
   end Clear;

   procedure Init is
   begin
      STM32.Board.Initialize_LEDs;
      Display.Initialize;
      Display.Initialize_Layer(1, RGB_565);
      Touch_Panel.Initialize;
      User_Button.Initialize;

      STM32.Board.Initialize_Gyro_IO;

      Gyro.Reset;

      Gyro.Configure
        (Power_Mode       => L3GD20_Mode_Active,
         Output_Data_Rate => L3GD20_Output_Data_Rate_95Hz,
         Axes_Enable      => L3GD20_Axes_Enable,
         Bandwidth        => L3GD20_Bandwidth_1,
         BlockData_Update => L3GD20_BlockDataUpdate_Continous,
         Endianness       => L3GD20_Little_Endian,
         Full_Scale       => L3GD20_Fullscale_250);

      Enable_Clock (MEMS_INT2);
      Configure_IO (MEMS_INT2, (Mode => Mode_In, Resistors => Floating));

      Configure_Trigger (MEMS_INT2, Interrupt_Rising_Edge);

      Gyro.Enable_Data_Ready_Interrupt;

      Clear(True);
   end Init;

   R0, R1, R2, R3 : Rectangles.RectangleAcc;
   W1 : Worlds.World;
   VecZero : constant Vec2D := (0.0, 0.0);
   Vec1, Vec2 : Vec2D;

   fps : constant Float := 24.0;
   dt : constant Float := 1.0 / fps;
   cd : constant Integer := 10; -- * dt

   -- if true, the world will no longer update (blue button)
   Frozen : Boolean := False;
   Cooldown : Integer := 0;
   Tick : Integer := 0;

begin
   -- Ceiling
   Vec1 := Vec2D'(x => 10.0, y => 0.0);
   Vec2 := Vec2D'(x => 220.0, y => 10.0);
   R0 := Rectangles.Create(Vec1, VecZero, VecZero, Vec2, Materials.STATIC);

   -- Floor
   Vec1 := Vec2D'(x => 0.0, y => 310.0);
   Vec2 := Vec2D'(x => 240.0, y => 10.0);
   R1 := Rectangles.Create(Vec1, VecZero, VecZero, Vec2, Materials.STATIC);

   -- Right wall
   Vec1 := Vec2D'(x => 230.0, y => 0.0);
   Vec2 := Vec2D'(x => 10.0, y => 310.0);
   R2 := Rectangles.Create(Vec1, VecZero, VecZero, Vec2, Materials.STATIC);

   -- Left wall
   Vec1 := Vec2D'(x => 0.0, y => 0.0);
   Vec2 := Vec2D'(x => 10.0, y => 310.0);
   R3 := Rectangles.Create(Vec1, VecZero, VecZero, Vec2, Materials.STATIC);

   W1.Init(dt);

   W1.Add(R0);
   W1.Add(R1);
   W1.Add(R2);
   W1.Add(R3);

   Init;
   loop

      if Cooldown > 0 then
         Cooldown := Cooldown - 1;
      end if;

      if not Frozen then
         Tick := Tick + 1;
         -- update the world for one tick (dt) with low sram usage
         -- InvalidEnt'Access is an access to a function that tells
         -- is an ent is valid or not (outside of the screen -> delete)
         W1.StepLowRAM(InvalidEnt'Access);
      end if;

      -- clear buffer for next render
      Clear(False);

      -- gets the user inputs and updates the world accordingly
      if Inputs(W1, Frozen, Cooldown) then
         Cooldown := cd; -- reset cooldown
      end if;

      -- renders
      Render(W1.GetEntities);

   end loop;

end AdaProject;
