package body Maps is
   
   function CreateMap(Txt : MapTXT ; Logic : InputLogic; dt : Float) return Map
   is
      W : World;
   begin
      W.Init(dt);
      
      
      return Map'(MapWorld => W, Logic => Logic, dt => dt);
   end CreateMap;

end Maps;
