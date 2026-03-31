package queue

import TTF "vendor:sdl3/ttf"
import SDL "vendor:sdl3"

renderQ: [dynamic]Command

CommandType :: enum u8 {
	RECT,
	FILLED_RECT,
	TEXT,
	DEBUG_TEXT,
	DEBUG_TEXT_FORMAT,
}

Command :: struct {
	type:  CommandType,
	color: SDL.Color,
	rectOrXY: union {
		^SDL.FRect,
		[2]f32,
	},
	text: union {
		cstring,
		^TTF.Text,
		FormattedString,
	},
}

FormattedString :: struct {
	fmt:  cstring,
	args: []any,
}

drawFilledRect :: proc(rect: ^SDL.FRect, color := SDL.Color{255, 255, 255, 255}) {
	append(&renderQ, Command{.FILLED_RECT, color, rect, nil})
}

drawRect :: proc(rect: ^SDL.FRect, color := SDL.Color{255, 255, 255, 255}) {
	append(&renderQ, Command{.RECT, color, rect, nil})
}

drawText :: proc(x, y: f32, text: ^TTF.Text, color := SDL.Color{255, 255, 255, 255}) {
	append(&renderQ, Command{.TEXT, color, [2]f32{x,y}, text})
}

drawDebugText :: proc(x, y: f32, text: cstring, color := SDL.Color{255, 255, 255, 255}) {
	append(&renderQ, Command{.DEBUG_TEXT, color, [2]f32{x,y}, text})
}

drawDebugTextFormat :: proc(x, y: f32, fmt: cstring, args: ..any, color := SDL.Color{255, 255, 255, 255}) {
	append(&renderQ, Command{.DEBUG_TEXT_FORMAT, color, [2]f32{x,y}, FormattedString{fmt, args}})
}

@(private)
oldColor : SDL.Color

render :: proc(renderer: ^SDL.Renderer) {
	for cmd in renderQ {
		if cmd.color != oldColor {
			SDL.SetRenderDrawColor(renderer, cmd.color.r, cmd.color.g, cmd.color.b, cmd.color.a)
			oldColor = cmd.color
		}
		 switch cmd.type {
			case .RECT:
				SDL.RenderRect(renderer, cmd.rectOrXY.(^SDL.FRect))
			case .FILLED_RECT:
				SDL.RenderFillRect(renderer, cmd.rectOrXY.(^SDL.FRect))
			case .TEXT:
				TTF.DrawRendererText(cmd.text.(^TTF.Text), cmd.rectOrXY.([2]f32).x, cmd.rectOrXY.([2]f32).y)
			case .DEBUG_TEXT:
				SDL.RenderDebugText(renderer, cmd.rectOrXY.([2]f32).x, cmd.rectOrXY.([2]f32).y, cmd.text.(cstring))
			case .DEBUG_TEXT_FORMAT:
				SDL.RenderDebugTextFormat(renderer, cmd.rectOrXY.([2]f32).x, cmd.rectOrXY.([2]f32).y, cmd.text)
		}
	}
}
