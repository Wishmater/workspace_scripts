#!/run/current-system/sw/bin/bash

# TODO: 2 get default terminal from env somehow, or figure out xdg.term-exec
terminal="ghostty"

echo "Creating cut-vim tmux session..."
tmux new -d -t cutrans -s cut-vim -c ~/workspaces/mpg_flutter
tmux send-keys "tmux rename-window cut-nvim" ENTER
echo "    done"

echo "Creating cut-bck tmux session..."
tmux new -d -t cutrans -s cut-bck -c ~/workspaces/mpg_flutter/backend
tmux send-keys "tmux new-window -n cut-backend" ENTER
echo "    done"

echo "Creating cut-frt tmux session..."
tmux new -d -t cutrans -s cut-frt -c ~/workspaces/mpg_flutter/frontend
tmux send-keys "tmux new-window -n cut-frontend" ENTER
tmux send-keys "tmux new-window -n cut-frontend-ov" ENTER
echo "    done"

echo "Setting up nvim tmux pane..."
tmux send-keys -t cut-nvim \
  "cd ~/workspaces/mpg_flutter" ENTER \
  "nix-shell" ENTER \
  "nvim" ENTER
echo "    done"

sleep 0.1 # avoid race condition that happens if script keeps going before tmux panes are resdy

echo "Setting up backend tmux pane..."
tmux send-keys -t cut-backend \
  "cd ~/workspaces/mpg_flutter/backend" ENTER \
  "nix-shell" ENTER \
  "ov --wrap=false --disable-mouse --follow-all -e" \
  " -- dart run --enable-vm-service --enable-asserts lib/bin/server.dart"
echo "    done"

echo "Setting up frontend tmux pane..."
tmux send-keys -t cut-frontend \
  "cd ~/workspaces/mpg_flutter/frontend" ENTER \
  "nix-shell" ENTER \
  "flutter run"
echo "    done"

echo "Setting up frontend-ov tmux pane..."
# hack to get output of another terminal https://www.reddit.com/r/commandline/comments/263afq/bashtmux_pipe_the_output_of_a_detached_tmux/
tmux send-keys -t cut-frontend-ov \
  "cd ~/workspaces/mpg_flutter/frontend" ENTER \
  "sudo mkdir -m 777 /run/tmux_out" \
  " ; rm -f /run/tmux_out/cutrans_frontend.txt" \
  " ; mkfifo /run/tmux_out/cutrans_frontend.txt" \
  " ; tmux pipe-pane -t cut-frontend -o 'cat >> /run/tmux_out/cutrans_frontend.txt'" \
  " ; ov --wrap=false --disable-mouse --follow-all /run/tmux_out/cutrans_frontend.txt"
echo "    done"

echo "Running $terminal windows for cut-vim..."
nohup $terminal -e tmux attach -t cut-vim >/dev/null 2>&1 &
echo "    done"

echo "Running $terminal windows for cut-bck..."
nohup $terminal -e tmux attach -t cut-bck >/dev/null 2>&1 &
echo "    done"

echo "Running $terminal windows for cut-frt..."
nohup $terminal -e tmux attach -t cut-frt >/dev/null 2>&1 &
echo "    done"
