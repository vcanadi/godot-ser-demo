## godot-ser-demo
Demo project that utilizes godot-lang's code autogeneration and godot-ser's serialization between Haskell and Godot code


### Usage

In nix shell:

Run server `runhaskell -isrc src/Net/Srv.hs`

Run Haskell client `runhaskell -isrc src/Net/Cli.hs`

Run Godot's client in Godot's main small-cl.gd that connects to running Haskell server

When changing the Haskell model update godot code with
`runhaskell -isrc src/Net/TH.hs`

