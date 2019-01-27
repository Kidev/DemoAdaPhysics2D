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
with MainMenu; use MainMenu;

-- Debug prints
with Ada.Exceptions; use Ada.Exceptions;
with LCD_Std_Out;
with BMP_Fonts;
with Utils;

procedure AdaProject is begin

   STM32.Board.Initialize_LEDs;
   Display.Initialize;
   Display.Initialize_Layer(1, RGB_565);
   Touch_Panel.Initialize;
   User_Button.Initialize;

   -- Debug prints
   LCD_Std_Out.Set_Font (BMP_Fonts.Font8x8);
   LCD_Std_Out.Current_Background_Color := Utils.BG;

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

   begin
      ShowMenu;
   exception
      when Error: others =>
         Utils.Clear(True);
         LCD_Std_Out.Put_Line(Exception_Information(Error));
         loop null; end loop;
   end;

end AdaProject;
