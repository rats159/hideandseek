package ui

import clay "../../libs/clay-odin"
import rl "vendor:raylib"

Modal :: struct {
	title: string,
	body:  string,
}

draw_modals :: proc(modal: Modal, data: ^UI_Data) {
    if clay.UI()({
        layout = {
            sizing = {clay.SizingGrow(),clay.SizingGrow()},
            childAlignment = {.Center, .Center}
        },
        floating = {
            zIndex = 999,
            attachTo = .Root
        }, 
        backgroundColor = {0,0,0,128}
    }) {
        draw_modal(modal,data)
    }
}

draw_modal :: proc(modal: Modal, data: ^UI_Data) {
    if clay.UI()({
        backgroundColor = {255,255,255,255},
        layout = {
            padding = clay.PaddingAll(16),
            layoutDirection = .TopToBottom
        },
        cornerRadius = clay.CornerRadiusAll(8)
    }) {
        centeredText(modal.title, clay.TextConfig({
            fontId = 0,
            fontSize = 48,
            textColor = {0,0,0,255}
        }))
        centeredText(modal.body, clay.TextConfig({
            fontId = 1,
            fontSize = 24,
            textColor = {0,0,0,255}
        }))
        if button("Ok") || rl.IsKeyPressed(.ESCAPE) {
            close_modal(data)
        }
    }
}

close_modal :: proc(data: ^UI_Data) {
    if data.modal == nil do return
    destroy_modal(data.modal.?)
    data.modal = nil
}

open_modal :: proc(modal: Modal, data: ^UI_Data) {
    if existing_modal, exists := data.modal.?; exists {
        destroy_modal(existing_modal)
    }
    data.modal = modal
}

destroy_modal :: proc(modal: Modal) {
    delete(modal.body)
    delete(modal.title)
}