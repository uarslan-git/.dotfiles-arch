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
    'thunderbird': workspace_vars['ws3'],
    'element': workspace_vars['ws3'],
    'vesktop': workspace_vars['ws3'],
    'discord': workspace_vars['ws3'],
    'zoom': workspace_vars['ws3'],
    'Gimp': workspace_vars['ws4'],
    'Davinci-Resolve': workspace_vars['ws4'],
    'Notion': workspace_vars['ws5'],
    'notion-calendar': workspace_vars['ws5'],
    'steam': workspace_vars['ws10'],
}

GAME_CLASSES = ['steam', 'dota2', 'cs2', 'hl2']

class MonitorManager:
    def __init__(self, i3):
        self.i3 = i3
        self.primary_monitor = None
        self.secondary_monitor = None
        self.gaming_mode = False
        self.update_monitor_info()

    def update_monitor_info(self):
        outputs = self.i3.get_outputs()
        active_outputs = [o for o in outputs if o.active]

        if len(active_outputs) < 2:
            print("Only one monitor detected")
            self.primary_monitor = active_outputs[0].name if active_outputs else None
            self.secondary_monitor = None
            self.gaming_mode = False
            return False

        workspaces = self.i3.get_workspaces()
        game_ws = next((ws for ws in workspaces if ws.name == workspace_vars['ws10'] and ws.visible), None)
        self.gaming_mode = game_ws is not None

        if self.gaming_mode:
            self.primary_monitor = game_ws.output
            self.secondary_monitor = next(
                (o.name for o in active_outputs if o.name != self.primary_monitor),
                active_outputs[0].name
            )
            print(f"Gaming mode active - Primary: {self.primary_monitor}, Secondary: {self.secondary_monitor}")
        else:
            focused_ws = next((ws for ws in workspaces if ws.focused), None)
            if focused_ws:
                self.primary_monitor = focused_ws.output
                self.secondary_monitor = next(
                    (o.name for o in active_outputs if o.name != self.primary_monitor),
                    active_outputs[0].name
                )
            else:
                self.primary_monitor = active_outputs[0].name
                self.secondary_monitor = active_outputs[1].name
            print(f"Normal mode - Primary: {self.primary_monitor}, Secondary: {self.secondary_monitor}")

        return True

    def get_workspace_for_window(self, window_class):
        for cls, workspace in WINDOW_WORKSPACE_MAP.items():
            if cls.lower() in window_class.lower():
                return workspace
        return None

    def is_game_window(self, window_class):
        return any(game_class.lower() in window_class.lower() for game_class in GAME_CLASSES)

    def bounce_window_if_needed(self, window):
        if not self.gaming_mode or not self.secondary_monitor:
            return False

        current_workspace = next((ws for ws in self.i3.get_workspaces() if ws.focused), None)
        if not current_workspace or current_workspace.name != workspace_vars['ws10']:
            return False

        window_class = window.window_class
        if self.is_game_window(window_class):
            return False

        target_workspace = self.get_workspace_for_window(window_class)
        if not target_workspace:
            target_workspace = workspace_vars['ws1']

        print(f"Bouncing non-game window from workspace 10 to {target_workspace}")
        window.command(f'move container to workspace "{target_workspace}"')
        self.ensure_workspace_on_correct_monitor(target_workspace)
        return True

    def ensure_workspace_on_correct_monitor(self, workspace_name):
        if not self.secondary_monitor:
            return False

        target_monitor = self.primary_monitor if workspace_name == workspace_vars['ws10'] else (
            self.secondary_monitor if self.gaming_mode else self.primary_monitor
        )

        workspaces = self.i3.get_workspaces()
        ws = next((ws for ws in workspaces if ws.name == workspace_name), None)

        if ws and ws.output != target_monitor:
            print(f"Moving {workspace_name} to {target_monitor}")
            self.i3.command(f'workspace "{workspace_name}"')
            self.i3.command(f'move workspace to output {target_monitor}')
            return True
        elif not ws:
            print(f"Creating {workspace_name} on {target_monitor}")
            self.i3.command(f'workspace "{workspace_name}"')
            self.i3.command(f'move workspace to output {target_monitor}')
            return True
        return False

def on_window_new(i3, e, manager):
    window = e.container
    window_class = window.window_class
    manager.update_monitor_info()

    if manager.bounce_window_if_needed(window):
        return

    target_workspace = manager.get_workspace_for_window(window_class)
    if not target_workspace:
        return

    print(f"Detected '{window_class}' -> '{target_workspace}'")
    manager.ensure_workspace_on_correct_monitor(target_workspace)
    window.command(f'move container to workspace "{target_workspace}"')

    if target_workspace != workspace_vars['ws10']:
        i3.command(f'workspace "{target_workspace}"')

def on_window_move(i3, e, manager):
    if e.change == "move":
        window = i3.get_tree().find_focused()
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

        def window_handler(i3, e):
            on_window_new(i3, e, manager)

        def move_handler(i3, e):
            on_window_move(i3, e, manager)

        def workspace_handler(i3, e):
            on_workspace_focus(i3, e, manager)

        i3.on("window::new", window_handler)
        i3.on("window::move", move_handler)
        i3.on("workspace::focus", workspace_handler)

        print("Enhanced workspace manager started")
        print("Gaming mode will trigger secondary monitor for apps")
        i3.main()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()

