with Rectangles;
with Worlds;
with Materials;
with Vectors2D; use Vectors2D;
with Renderer; use Renderer;
with DemoLogic; use DemoLogic;
with Utils; use Utils;

package body AdaPhysics2DDemo is

   procedure Start
   is
      SCeiling, SFloor, SRight, SLeft : Rectangles.RectangleAcc;
      EAir, EWater : Rectangles.RectangleAcc;
      W1 : Worlds.World;
      VecZero : constant Vec2D := (0.0, 0.0);
      Vec1, Vec2 : Vec2D;

      MaxEnt : constant Natural := 32; -- max ents + envs. 0 = unlimited
      fps : constant Float := 30.0;
      dt : constant Float := 1.0 / fps;
      cd : constant Integer := 10; -- * dt | cooldown
      
      Cue : VisualCue;

      -- if true, the world will no longer update
      Frozen : Boolean := False;
      Cooldown : Integer := 0;
      Tick : Integer := 0;
   begin
      -- Ceiling
      Vec1 := Vec2D'(x => 10.0, y => 0.0);
      Vec2 := Vec2D'(x => 220.0, y => 10.0);
      SCeiling := Rectangles.Create(Vec1, VecZero, VecZero, Vec2, Materials.STATIC);

      -- Floor
      Vec1 := Vec2D'(x => 0.0, y => 310.0);
      Vec2 := Vec2D'(x => 240.0, y => 10.0);
      SFloor := Rectangles.Create(Vec1, VecZero, VecZero, Vec2, Materials.STATIC);

      -- Right wall
      Vec1 := Vec2D'(x => 230.0, y => 0.0);
      Vec2 := Vec2D'(x => 10.0, y => 310.0);
      SRight := Rectangles.Create(Vec1, VecZero, VecZero, Vec2, Materials.STATIC);

      -- Left wall
      Vec1 := Vec2D'(x => 0.0, y => 0.0);
      Vec2 := Vec2D'(x => 10.0, y => 310.0);
      SLeft := Rectangles.Create(Vec1, VecZero, VecZero, Vec2, Materials.STATIC);
      
      -- Top vacuum env
      Vec1 := Vec2D'(x => 10.0, y => 10.0);
      Vec2 := Vec2D'(x => 220.0, y => 250.0);
      EAir := Rectangles.Create(Vec1, VecZero, VecZero, Vec2, Materials.AIR);
      
      -- Bottom water env
      Vec1 := Vec2D'(x => 10.0, y => 250.0);
      Vec2 := Vec2D'(x => 220.0, y => 60.0);
      EWater := Rectangles.Create(Vec1, VecZero, VecZero, Vec2, Materials.WATER);

      W1.Init(dt, MaxEnt);
      W1.SetInvalidChecker(InvalidEnt'Access);

      W1.AddEnvironment(EAir);
      W1.AddEnvironment(EWater);

      W1.AddEntity(SCeiling);
      W1.AddEntity(SFloor);
      W1.AddEntity(SRight);
      W1.AddEntity(SLeft);
   
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
         if Inputs(W1, Frozen, Cooldown, Cue) then
            Cooldown := cd; -- reset cooldown
         end if;
         
         -- renders
         Render(W1, Cue);

      end loop;
      
      --W1.Free;
      
   end Start;

end AdaPhysics2DDemo;
