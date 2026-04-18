package SDL.Raw.Video_Types is
   pragma Pure;

   type Window_ID is mod 2 ** 32 with
     Convention => C,
     Size       => 32;
end SDL.Raw.Video_Types;
