with Worlds; use Worlds;
with GameLogic;

package Maps is
   
   Tile : constant Natural := 10;
   TileX : constant Natural := (240 / Tile);
   TileY : constant Natural := (320 / Tile);
   
   type MapTXT is array (1 .. TileY, 1 .. TileX) of Character;
   
   type InputLogic is access function (W : in out World; Frozen : in out Boolean; Cooldown : Integer) return Boolean;

   type Map is record
      MapWorld  : World;
      Logic : InputLogic := null;
      dt : Float := 0;
   end record;
   
   function CreateMap(Txt : MapTXT ; Logic : InputLogic; dt : Float) return Map;
   
   -- Mapping
   -- = linear static wall, | horizontal static wall
   -- S full (no edges) rect 'S'tatic entity
   -- r ('r'ubber) entity circle with radius = tile / 2 that is not in the win layer
   -- $ win entity in win layer (no collisions, has to be done in logic)
   function Map1 return Map
   is
      MapStr : MapTXT :=
        (1 => ("========================"),
         2 => ("|                      |"),
         3 => ("|   r                  |"),
         4 => ("|                      |"),
         5 => ("|                      |"),
         6 => ("|                      |"),
         7 => ("|                      |"),
         8 => ("|                      |"),
         9 => ("|                      |"),
         10=> ("|                      |"),
         11=> ("|                      |"),
         12=> ("|                      |"),
         13=> ("|                      |"),
         14=> ("|                      |"),
         15=> ("|SSSSSSSSSSSSSSSS      |"),
         16=> ("|SSSSSSSSSSSSSSSS      |"),
         17=> ("$                      |"),
         18=> ("$                      |"),
         19=> ("|                      |"),
         20=> ("|                      |"),
         21=> ("|                      |"),
         22=> ("|                      |"),
         23=> ("|                      |"),
         24=> ("|                      |"),
         25=> ("|                      |"),
         26=> ("|                      |"),
         27=> ("|                      |"),
         28=> ("|                      |"),
         29=> ("|                      |"),
         30=> ("|                      |"),
         31=> ("|                      |"),
         32=> ("=========$$$$$=========="));
   begin
      return CreateMap(MapStr, GameLogic.Inputs'Access, 1.0 / 24.0);
   end Map1;
      
   

end Maps;
