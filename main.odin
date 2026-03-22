package main

import "core:os"
import SDL "vendor:sdl3"
import TTF "vendor:sdl3/ttf"
import "core:strings"

window       : ^SDL.Window
renderer     : ^SDL.Renderer
font         : ^TTF.Font
textEngine   : ^TTF.TextEngine

deltaTime    : f32
camX, camY   : f32

gameRunning  : = false

keyboardState  : [^]bool
mouseState     : SDL.MouseButtonFlags
mouseX, mouseY : f32

windowWidth, windowHeight : i32 = 640, 480

init :: proc() -> bool {
    // sdl stuff
    if !(SDL.SetAppMetadata("cool game", "0.1", "com.food.coolgame") && SDL.Init(SDL.INIT_VIDEO)) do return false


    window   = SDL.CreateWindow("cool game", windowWidth, windowHeight, SDL.WINDOW_RESIZABLE)
    renderer = SDL.CreateRenderer(window, nil)

    // enable vsync
    SDL.SetRenderVSync(renderer, 1)

    // ttf stuff
    TTF.Init();
    textEngine    = TTF.CreateRendererTextEngine(renderer)
    fontPath, err := os.join_path({string(SDL.GetBasePath()), "assets/cozette.fnt"}, context.allocator)
    font          = TTF.OpenFont(strings.clone_to_cstring(fontPath), 13)

    gameRunning = true
    return true
}

exit :: proc() {
    TTF.CloseFont(font)
    TTF.Quit()

    SDL.DestroyRenderer(renderer)
    SDL.DestroyWindow(window)
    SDL.Quit()
}

render :: proc() {
	SDL.RenderDebugTextFormat(renderer, 0, 0, "hi")
}

mouse :: struct {
	x, y : f32
	
}

input :: proc(event: ^SDL.Event) {
	keyboardState = SDL.GetKeyboardState(nil)
	mouseState = SDL.GetMouseState(&mouseX, &mouseY)
	
	if event.type == SDL.EventType.QUIT {
        gameRunning = false;
    }

    if event.type == SDL.EventType.WINDOW_RESIZED {
        SDL.GetWindowSizeInPixels(window, &windowWidth, &windowHeight);
    }
    
}

main :: proc() {
	if !init() do return

	for ;gameRunning; {
        currentTick := SDL.GetTicks()

        event : SDL.Event
        for ;SDL.PollEvent(&event); {
            input(&event)
        }

        render()

        deltaTime = f32(SDL.GetTicks() - currentTick) / 1000.0
    }

	exit()
}
