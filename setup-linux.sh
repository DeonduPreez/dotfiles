#!/bin/bash
# Bash script to setup symlinks for dotfiles

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Function to create symlinks
create_symlink() {
    local subdirectory="$1"
    local target="$2"

    # Get the directory where this script is located
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local source="$script_dir/$subdirectory"

    echo "Linking $subdirectory"

    # Check if target already exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        # Check if it's already a symlink pointing to our source
        if [ -L "$target" ]; then
            local link_target="$(readlink -f "$target")"
            if [ "$link_target" = "$source" ]; then
                echo -e "${GREEN}Symlink for $subdirectory already exists and points to the correct location.${NC}"
                return
            else
                echo -e "${YELLOW}A symlink already exists for $subdirectory but points to: $link_target${NC}"
                read -p "Remove existing symlink and create new one? (y/n) " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    echo -e "${YELLOW}Aborting.${NC}"
                    return
                fi
                rm -f "$target"
            fi
        else
            echo -e "${YELLOW}Directory $target already exists and is not a symlink.${NC}"
            read -p "Remove existing directory and create symlink? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}Aborting.${NC}"
                return
            fi
            rm -rf "$target"
        fi
    fi

    # Create parent directory if it doesn't exist
    local target_dir="$(dirname "$target")"
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi

    # Create the symlink
    echo -e "${CYAN}Creating symlink from $target to $source${NC}"
    ln -s "$source" "$target"

    if [ -L "$target" ]; then
        echo -e "${GREEN}Symlink created successfully!${NC}"
        echo -e "${GRAY}  Source: $source${NC}"
        echo -e "${GRAY}  Target: $target${NC}"
    else
        echo -e "${RED}Failed to create symlink.${NC}"
    fi
}

# Create symlinks
create_symlink "nvim" "$HOME/.config/nvim"
create_symlink "wezterm" "$HOME/.config/wezterm"
create_symlink "ghostty" "$HOME/.config/ghostty"
