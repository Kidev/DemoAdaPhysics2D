with Rectangles;
with Worlds;
with Materials;
with Vectors2D; use Vectors2D;
with Renderer; use Renderer;
with GameLogic; use GameLogic;
with Utils; use Utils;

package body AdaPhysics2DDemo is

   procedure Start
   is
      R0, R1, R2, R3 : Rectangles.RectangleAcc;
      W1 : Worlds.World;
      VecZero : constant Vec2D := (0.0, 0.0);
      Vec1, Vec2 : Vec2D;

      fps : constant Float := 24.0;
      dt : constant Float := 1.0 / fps;
      cd : constant Integer := 10; -- * dt | cooldown

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
      W1.SetInvalidChecker(InvalidEnt'Access);
      W1.SetEnvironment(Materials.AIR);

      W1.Add(R0);
      W1.Add(R1);
      W1.Add(R2);
      W1.Add(R3);
   
      Clear(True);
   
      loop

         if Cooldown > 0 then
            Cooldown := Cooldown - 1;
         end if;

         if not Frozen then
            Tick := Tick + 1;
            -- update the world for one tick (dt) with low sram usage
            -- InvalidEnt'Access is an access to a function that tells
            -- is an ent is valid or not (outside of the screen -> delete)
            W1.StepLowRAM;
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
   end Start;

end AdaPhysics2DDemo;
