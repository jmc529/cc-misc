return {
   source_dir = "src",
   build_dir = "build",
   gen_target = "5.1",
   -- betterTurtleAPI's modules are required as `modules.x`, the way they
   -- resolve in-game once the API's directory is the working directory.
   include_dir = { ".", "src/turtles/betterTurtleAPI" },
   global_env_def = "cc-tweaked"
}