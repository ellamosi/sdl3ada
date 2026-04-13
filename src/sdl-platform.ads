package SDL.Platform is
   pragma Preelaborate;

   type Platforms is (Windows, Mac_OS_X, Linux, BSD, iOS, Android, Unknown);

   function Name return String with
     Inline => True;

   function Get return Platforms with
     Inline => True;
end SDL.Platform;
