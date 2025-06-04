#!/usr/bin/env python3
import i3ipc
import math

class AutoTiler:
    def __init__(self, i3):
        self.i3 = i3
        self.last_layout = {}
        
    def get_output_geometry(self, output_name):
        outputs = self.i3.get_outputs()
        output = next((o for o in outputs if o.name == output_name), None)
        if output:
            return (output.rect.width, output.rect.height)
        return (1920, 1080)  # Default resolution
    
    def calculate_best_layout(self, workspace):
        output_name = workspace.output
        width, height = self.get_output_geometry(output_name)
        aspect_ratio = width / height
        
        # Wide screen (ultrawide)
        if aspect_ratio > 2.0:
            return "splitv"  # Vertical split for ultrawide
        # Tall screen
        elif aspect_ratio < 0.8:
            return "splith"  # Horizontal split for tall screens
        # Regular screen
        else:
            # Alternate between horizontal and vertical based on window count
            windows = len(workspace.leaves())
            if windows % 2 == 0:
                return "splith"
            else:
                return "splitv"
    
    def on_window_focus(self, i3, e):
        focused = i3.get_tree().find_focused()
        if not focused or not focused.workspace():
            return
        
        workspace = focused.workspace()
        layout = self.calculate_best_layout(workspace)
        
        # Only change layout if it's different from last time
        if workspace.name not in self.last_layout or self.last_layout[workspace.name] != layout:
            i3.command(f'workspace "{workspace.name}"')
            i3.command(f'layout {layout}')
            self.last_layout[workspace.name] = layout

def main():
    i3 = i3ipc.Connection()
    tiler = AutoTiler(i3)
    
    i3.on("window::focus", tiler.on_window_focus)
    
    print("Auto-tiling script running...")
    i3.main()

if __name__ == "__main__":
    main()
