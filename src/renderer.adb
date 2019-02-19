with STM32.Board; use STM32.Board;
with Circles; use Circles;
with Rectangles; use Rectangles;

package body Renderer is
   
   procedure Render(W : in out World; Cue : VisualCue)
   is
   begin
      RenderList(W.GetEnvironments);
      RenderList(W.GetEntities, Cue.Selected);
      RenderLinksList(W.GetLinks);
      RenderCue(Cue);
      
      Display.Update_Layer(1, Copy_Back => True);
   end Render;
   
   -- TODO implement GetRandomBezierPointFor & make one for springs (maybe)
   procedure RenderLinksList(L : LinksListAcc)
   is
      use LinksList;
      Curs : LinksList.Cursor := L.First;
      CurLink : LinkAcc;
   begin
      while Curs /= LinksList.No_Element loop
         CurLink := LinksList.Element(Curs);
         Display.Hidden_Buffer(1).Set_Source(GetLinkColor(CurLink));
         case CurLink.LinkType is
            when LTRope => DrawRope(CurLink);
            when LTSpring => DrawSpring(CurLink);
         end case;
         Curs := LinksList.Next(Curs);
      end loop;
   end RenderLinksList;
   
   procedure DrawRope(Link : LinkAcc)
   is
   begin
      Display.Hidden_Buffer(1).Bezier((GetCenteredPos(Link.A),
                                      GetBezierPoint(Link, 1, 3),
                                      GetBezierPoint(Link, 2, 3),
                                      GetCenteredPos(Link.B)), 20, 1);
   end DrawRope;
   
   procedure DrawSpring(Link : LinkAcc)
   is
      Dist : constant Float := 10.0; -- Dist > 0.0
      N : constant Natural := Natural(Link.RestLen / Dist);
      PLast : Point := GetBezierPoint(Link, 0, N, Dist);
      PNext : Point;
   begin
      if N = 0 then
         Display.Hidden_Buffer(1).Draw_Line(PLast, GetCenteredPos(Link.B), 1);
      else
         for I in 1 .. N loop
            PNext := GetBezierPoint(Link, I, N, Dist);
            Display.Hidden_Buffer(1).Draw_Line(PLast, PNext, 1);
            PLast := PNext;
         end loop;
      end if;
   end DrawSpring;
   
   function GetCenteredPos(E : EntityClassAcc) return Point
   is
   begin
      return GetIntCoords(E.GetPosition);
   end GetCenteredPos;
   
   function GetBezierPoint(Link : LinkAcc; i : Natural; n : Positive; UseMul : Float := 0.0) return Point
   is
      P0 : constant Vec2D := Link.A.GetPosition;
      Pn : constant Vec2D := Link.B.GetPosition;
      Len : constant Float := Mag(Pn - P0);
      Dir : constant Vec2D := (1.0 / Len) * (Pn - P0);
      Normal : constant Vec2D := Dir.Normal;
      X : constant Float := (if UseMul = 0.0 then Link.RestLen - Len else UseMul);
      Pi : Vec2D := ((Len / Float(n)) * Float(i) * Dir) + P0;
   begin
      if i = 0 then return GetIntCoords(P0); end if;
      if i = n then return GetIntCoords(Pn); end if;
      if X < 0.0 and UseMul = 0.0 then return GetIntCoords(P0); end if;
      Pi := ((if i mod 2 = 0 then 1.0 else -1.0) * Normal * X) + Pi;
      return GetIntCoords(Pi);
   end GetBezierPoint;
   
   procedure RenderCue(Cue : VisualCue) is
   begin
      if Cue.R >= 0 then
         Display.Hidden_Buffer(1).Set_Source(GetColor(Cue.Mat));
         case Cue.EntType is
            when EntCircle =>
               Display.Hidden_Buffer(1).Draw_Circle((Cue.X, Cue.Y), Cue.R);
            when EntRectangle =>
               Display.Hidden_Buffer(1).Draw_Rect(((Cue.X, Cue.Y), Cue.R, Cue.R));
         end case;
      end if;
   end RenderCue;

   procedure RenderList(L : EntsListAcc; Selected : EntityClassAcc := null)
   is
      use EntsList;
      Curs : EntsList.Cursor := L.First;
      E : EntityClassAcc;
   begin
      
      while Curs /= EntsList.No_Element loop
         
         E := EntsList.Element(Curs);
         
         if E /= Selected then
            Display.Hidden_Buffer(1).Set_Source(GetColor(E.Mat));
         else
            Display.Hidden_Buffer(1).Set_Source(Opposite(GetColor(E.Mat)));
         end if;
         
         case E.all.EntityType is

            when EntCircle =>
               declare
                  C : constant CircleAcc := CircleAcc(E);
               begin
                  if C.all.InvMass = 0.0 or else not IsSolidMaterial(C.Mat) then
                      Display.Hidden_Buffer(1).Fill_Circle
                       (
                        Center => GetIntCoords(C.all.Coords),
                        Radius => Integer(C.all.Radius)
                       );                    
                  else
                     Display.Hidden_Buffer(1).Draw_Circle
                       (
                        Center => GetIntCoords(C.all.Coords),
                        Radius => Integer(C.all.Radius)
                       );
                  end if;
               end;
               
            when EntRectangle =>
               declare
                  R : constant RectangleAcc := RectangleAcc(E);
               begin
                  if R.all.InvMass = 0.0 or else not IsSolidMaterial(R.Mat) then
                     Display.Hidden_Buffer(1).Fill_Rect
                       (
                        Area => (Position => GetIntCoords(R.all.Coords),
                                 Height => Natural(R.all.GetHeight),
                                 Width => Natural(R.all.GetWidth))
                       );
                  else
                      Display.Hidden_Buffer(1).Draw_Rect
                       (
                        Area => (Position => GetIntCoords(R.all.Coords),
                                 Height => Natural(R.all.GetHeight),
                                 Width => Natural(R.all.GetWidth))
                       );                    
                  end if;
               end;
         end case;
         
         Curs := EntsList.Next(Curs);

      end loop;
      
   end RenderList;
   
   function GetColor(Mat : in Material) return Bitmap_Color
   is
   begin
      case Mat.MType is
         when MTStatic => return Green;
         when MTSteel => return Silver;
         when MTIce => return Blue;
         when MTConcrete => return Grey;
         when MTRubber => return Red;
         when MTWood => return Brown;
         when MTBalloon => return White;
         when ETVacuum => return Black;
         when ETAir => return Dim_Grey;
         when ETWater => return Aqua;
      end case;
   end GetColor;
   
   function GetLinkColor(L : LinkAcc) return Bitmap_Color
   is
   begin
      if L.Factor = LinkTypesFactors(LTRope) then
         return Red;
      elsif L.Factor = LinkTypesFactors(LTSpring) then
         return Orange;
      end if;
      return White;
   end GetLinkColor;
   
   function InvalidEnt(E : EntityClassAcc) return Boolean
   is
   begin
      if E = null then return True; end if;
      if E.Coords.x < 0.0 or E.Coords.x > 240.0 then return True; end if;
      if E.Coords.y < 0.0 or E.Coords.y > 320.0 then return True; end if;
      return False;
   end InvalidEnt;

   function GetIntCoords(flCoords : Vec2D) return Point
   is
      retCoords : Vec2D;
   begin
      retCoords := flCoords;
      
      if retCoords.x < 0.0 or retCoords.x > 240.0 then
         retCoords.x := 0.0;
      end if;
      if retCoords.y < 0.0 or retCoords.y > 320.0 then
         retCoords.y := 0.0;
      end if;
      
      return Point'(Natural(retCoords.x), Natural(retCoords.y));
   end getIntCoords;

end Renderer;
