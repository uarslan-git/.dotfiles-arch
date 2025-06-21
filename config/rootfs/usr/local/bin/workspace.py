#!/usr/bin/env python3
import i3ipc
import os
from pathlib import Path

def get_socket_path():
    if 'I3SOCK' in os.environ:
        return os.environ['I3SOCK']
    user_id = os.getuid()
    possible_paths = [
        f'/run/user/{user_id}/i3/ipc-socket.{user_id}',
        f'/tmp/i3-{user_id}-0/ipc-socket.{user_id}',
    ]
    for path in possible_paths:
        if Path(path).exists():
            return path
    return None

workspace_vars = {
    'ws1': "1:一",
    'ws2': "2:二",
    'ws3': "3:三",
    'ws4': "4:四",
    'ws5': "5:五",
    'ws6': "6:六",
    'ws7': "7:七",
    'ws8': "8:八",
    'ws9': "9:九",
    'ws10': "10:十",
}

WINDOW_WORKSPACE_MAP = {
    'kitty': workspace_vars['ws1'],
    'Google-chrome': workspace_vars['ws2'],
    'firefox': workspace_vars['ws2'],
    'thunderbird': workspace_vars['ws3'],
    'element': workspace_vars['ws3'],
    'vesktop': workspace_vars['ws3'],
    'discord': workspace_vars['ws3'],
    'zoom': workspace_vars['ws3'],
    'Gimp': workspace_vars['ws4'],
    'unity': workspace_vars['ws4'],
    'unityhub': workspace_vars['ws4'],
    'kdenlive': workspace_vars['ws4'],
    'Davinci-Resolve': workspace_vars['ws4'],
    'Notion': workspace_vars['ws5'],
    'notion-calendar': workspace_vars['ws5'],
    'steamwebhelper': workspace_vars['ws10'],
    'steam': workspace_vars['ws10'],
}

GAME_CLASSES = ['steam', 'dota2', 'cs2', 'hl2']

class MonitorManager:
    def __init__(self, i3):
        self.i3 = i3
        self.primary_monitor = None
        self.secondary_monitor = None
        self.gaming_mode = False
        self.gaming_monitor = None
        self.update_monitor_info()

    def update_monitor_info(self):
        outputs = self.i3.get_outputs()
        active_outputs = [o for o in outputs if o.active]
        
        # Reset monitors before determining
        self.primary_monitor = None
        self.secondary_monitor = None
        self.gaming_mode = False
        self.gaming_monitor = None

        if len(active_outputs) < 2:
            print("Only one monitor detected. Gaming mode not applicable.")
            self.primary_monitor = active_outputs[0].name if active_outputs else None
            return False

        # Determine gaming mode and assign monitors
        if self.is_gaming_workspace_active():
            workspaces = self.i3.get_workspaces()
            game_ws = next((ws for ws in workspaces if ws.name == workspace_vars['ws10']), None)
            
            if game_ws:
                self.gaming_mode = True
                self.gaming_monitor = game_ws.output
                # The primary monitor will be the one *not* used for gaming
                self.primary_monitor = next((o.name for o in active_outputs if o.name != self.gaming_monitor), None)
                self.secondary_monitor = self.gaming_monitor # Keep for clarity, though not directly used for non-gaming apps
                print(f"Gaming mode active - Game on {self.gaming_monitor}, non-gaming apps to {self.primary_monitor}")
                self.evacuate_windows_from_gaming_monitor()
                return True
        
        # If not in gaming mode or only one monitor
        focused_ws = next((ws for ws in self.i3.get_workspaces() if ws.focused), None)
        if focused_ws:
            self.primary_monitor = focused_ws.output
            self.secondary_monitor = next(
                (o.name for o in active_outputs if o.name != self.primary_monitor),
                active_outputs[0].name if active_outputs else None
            )
        else:
            self.primary_monitor = active_outputs[0].name if active_outputs else None
            self.secondary_monitor = active_outputs[1].name if len(active_outputs) > 1 else None
        
        print(f"Normal mode - Primary: {self.primary_monitor}, Secondary: {self.secondary_monitor}")
        return True


    def get_workspace_for_window(self, window_class):
        for cls, workspace in WINDOW_WORKSPACE_MAP.items():
            if cls.lower() in window_class.lower():
                return workspace
        return None

    def is_game_window(self, window_class):
        return any(game_class.lower() in window_class.lower() for game_class in GAME_CLASSES)

    def is_gaming_workspace_active(self):
        tree = self.i3.get_tree()
        for window in tree.leaves():
            ws = window.workspace()
            if ws and ws.name == workspace_vars['ws10']:
                if self.is_game_window(window.window_class):
                    return True
        return False

    def bounce_window_if_needed(self, window):
        # This function is primarily for non-game windows that somehow ended up on workspace 10
        if not self.gaming_mode or not self.gaming_monitor:
            return False

        ws = window.workspace()
        if not ws or ws.name != workspace_vars['ws10']:
            return False # Only bounce if on ws10

        window_class = window.window_class
        if self.is_game_window(window_class):
            return False # Don't bounce game windows

        target_workspace = self.get_workspace_for_window(window_class) or workspace_vars['ws1']
        
        # Ensure target workspace is on the non-gaming monitor
        if not self.ensure_workspace_on_correct_monitor(target_workspace, self.primary_monitor):
            print(f"Failed to ensure workspace {target_workspace} on {self.primary_monitor}.")
            return False

        print(f"Bouncing non-game window '{window.window_class}' from workspace 10 to {target_workspace} on {self.primary_monitor}")
        window.command(f'move container to workspace "{target_workspace}"')
        return True

    def evacuate_windows_from_gaming_monitor(self):
        # This function moves non-game windows from the gaming monitor to their intended workspaces
        if not self.gaming_mode or not self.gaming_monitor or not self.primary_monitor:
            return

        tree = self.i3.get_tree()
        for window in tree.leaves():
            if window.window_class and not self.is_game_window(window.window_class):
                # Check if the window is currently on the gaming monitor
                window_output = window.ipc_data.get("output")
                if window_output == self.gaming_monitor:
                    target_workspace = self.get_workspace_for_window(window.window_class) or workspace_vars['ws1']
                    
                    # Ensure the target workspace for this evacuated window is on the non-gaming monitor
                    if self.ensure_workspace_on_correct_monitor(target_workspace, self.primary_monitor):
                        print(f"Evacuating '{window.window_class}' to workspace '{target_workspace}' on {self.primary_monitor}")
                        window.command(f'move container to workspace "{target_workspace}"')
                    else:
                        print(f"Could not evacuate '{window.window_class}': Failed to set workspace {target_workspace} on {self.primary_monitor}")


    def ensure_workspace_on_correct_monitor(self, workspace_name, target_monitor):
        if not target_monitor:
            print(f"No target monitor specified for workspace '{workspace_name}'.")
            return False

        workspaces = self.i3.get_workspaces()
        existing_ws = next((ws for ws in workspaces if ws.name == workspace_name), None)

        if existing_ws:
            if existing_ws.output != target_monitor:
                print(f"Moving existing workspace '{workspace_name}' to monitor '{target_monitor}'.")
                # Focus the workspace, then move it to the target monitor
                self.i3.command(f'workspace "{workspace_name}"')
                self.i3.command(f'move workspace to output "{target_monitor}"')
                # After moving, it's good practice to re-focus the original workspace if applicable
                # (though for spawning new windows, the next command will handle it)
                return True
            else:
                return True # Workspace already on the correct monitor
        else:
            # Workspace doesn't exist, create it on the target monitor
            print(f"Creating workspace '{workspace_name}' on monitor '{target_monitor}'.")
            self.i3.command(f'workspace "{workspace_name}"')
            self.i3.command(f'move workspace to output "{target_monitor}"')
            return True

def on_window_new(i3, e, manager):
    window = e.container
    manager.update_monitor_info() # Re-evaluate monitor states on new window

    # If the window is a game window, let it spawn on ws10 if mapped
    if manager.is_game_window(window.window_class) and manager.get_workspace_for_window(window.window_class) == workspace_vars['ws10']:
        print(f"Detected game window '{window.window_class}'. Allowing it to go to {workspace_vars['ws10']}.")
        manager.ensure_workspace_on_correct_monitor(workspace_vars['ws10'], manager.gaming_monitor if manager.gaming_mode else manager.primary_monitor)
        window.command(f'move container to workspace "{workspace_vars["ws10"]}"')
        return

    # For non-game windows
    target_workspace = manager.get_workspace_for_window(window.window_class)
    if not target_workspace:
        print(f"No specific workspace mapping for '{window.window_class}'.")
        return

    # If in gaming mode, and it's not the gaming workspace
    if manager.gaming_mode and target_workspace != workspace_vars['ws10']:
        # Ensure the target non-gaming workspace is on the primary (non-gaming) monitor
        if not manager.primary_monitor:
            print(f"Error: No primary monitor available for non-gaming apps in gaming mode.")
            return

        if manager.ensure_workspace_on_correct_monitor(target_workspace, manager.primary_monitor):
            print(f"Detected '{window.window_class}' -> '{target_workspace}' on {manager.primary_monitor}")
            window.command(f'move container to workspace "{target_workspace}"')
        else:
            print(f"Failed to ensure workspace '{target_workspace}' on {manager.primary_monitor} for window '{window.window_class}'.")
    else:
        # If not in gaming mode, or if it's the gaming workspace
        # Ensure the target workspace is on the current primary monitor
        if not manager.primary_monitor:
            print(f"Error: No primary monitor available.")
            return
        
        if manager.ensure_workspace_on_correct_monitor(target_workspace, manager.primary_monitor):
            print(f"Detected '{window.window_class}' -> '{target_workspace}' on {manager.primary_monitor} (normal mode or gaming workspace).")
            window.command(f'move container to workspace "{target_workspace}"')
        else:
            print(f"Failed to ensure workspace '{target_workspace}' on {manager.primary_monitor} for window '{window.window_class}'.")


def on_window_move(i3, e, manager):
    if e.change == "move":
        window = i3.get_tree().find_focused()
        if window:
            manager.bounce_window_if_needed(window)

def on_workspace_focus(i3, e, manager):
    manager.update_monitor_info()

def main():
    socket_path = get_socket_path()
    if not socket_path:
        print("Error: Could not find i3 IPC socket")
        return

    try:
        i3 = i3ipc.Connection(socket_path=socket_path)
        manager = MonitorManager(i3)

        i3.on("window::new", lambda i3, e: on_window_new(i3, e, manager))
        i3.on("window::move", lambda i3, e: on_window_move(i3, e, manager))
        i3.on("workspace::focus", lambda i3, e: on_workspace_focus(i3, e, manager))
        i3.on("output::change", lambda i3, e: manager.update_monitor_info()) # Added for dynamic monitor changes

        print("Enhanced workspace manager started")
        print("Gaming mode will trigger secondary monitor for other apps")
        i3.main()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
