#!/usr/bin/env python3
import subprocess
import sys
import json

def run_i3msg(command):
    result = subprocess.run(['i3-msg', '-t', 'get_'+command], capture_output=True, text=True)
    return json.loads(result.stdout)

def get_current_workspace_and_output(workspaces):
    for ws in workspaces:
        if ws.get('focused'):
            return ws['name'], ws['output']
    return None, None

def main():
    if len(sys.argv) != 2 or sys.argv[1] not in ['left', 'right']:
        print(f"Usage: {sys.argv[0]} left|right")
        sys.exit(1)

    direction = sys.argv[1]

    # Get workspaces and outputs info
    workspaces = run_i3msg('workspaces')
    outputs = run_i3msg('outputs')

    current_ws, current_output = get_current_workspace_and_output(workspaces)

    # Get active outputs sorted by x position
    active_outputs = [o for o in outputs if o['active']]
    active_outputs.sort(key=lambda o: o['rect']['x'])

    # Find index of current output
    output_names = [o['name'] for o in active_outputs]
    try:
        current_index = output_names.index(current_output)
    except ValueError:
        print("Current output not found among active outputs")
        sys.exit(1)

    # Calculate new output index
    if direction == 'left':
        new_index = current_index - 1
    else:
        new_index = current_index + 1

    if new_index < 0 or new_index >= len(active_outputs):
        # No output in that direction
        sys.exit(0)

    new_output = active_outputs[new_index]['name']

    # Move workspace
    subprocess.run(['i3-msg', 'workspace', current_ws])
    subprocess.run(['i3-msg', 'move', 'workspace', 'to', 'output', new_output])

if __name__ == '__main__':
    main()

