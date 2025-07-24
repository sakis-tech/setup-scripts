#!/bin/bash

# =============================================================================
# Comprehensive System Setup Script - Enhanced Version
# Author: sakis-tech
# Description: Stable, user-friendly automated setup script
# Repository: https://github.com/sakis-tech/setup-scripts
# =============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Colors and formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color
readonly BOLD='\033[1m'

# Global configuration
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_NAME="sakis-tech-setup"
readonly REPO_URL="https://github.com/sakis-tech/setup-scripts.git"
readonly INSTALL_DIR="$HOME/$SCRIPT_NAME"
readonly LOG_DIR="$HOME/.local/share/$SCRIPT_NAME/logs"
readonly CONFIG_DIR="$HOME/.config/$SCRIPT_NAME"

# System detection
DISTRO=""
PACKAGE_MANAGER=""
USER_HOME="$HOME"
CURRENT_USER="$(whoami)"
IS_ROOT=false

# Installation state
INSTALL_USER=""
SELECTED_COMPONENTS=()

# =============================================================================
# Utility Functions
# =============================================================================

# Logging setup
setup_logging() {
    mkdir -p "$LOG_DIR"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    readonly LOGFILE="$LOG_DIR/setup-$timestamp.log"
    
    # Redirect all output to both console and log
    exec 1> >(tee -a "$LOGFILE")
    exec 2> >(tee -a "$LOGFILE" >&2)
}

# Print functions with consistent formatting
print_header() {
    echo -e "\n${CYAN}${BOLD}▓▓▓ $1 ▓▓▓${NC}\n"
}

print_section() {
    echo -e "\n${WHITE}${BOLD}━━━ $1 ━━━${NC}"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# Enhanced progress indicator
show_progress() {
    local duration=$1
    local message=$2
    local width=40
    
    echo -n -e "${YELLOW}$message${NC} "
    
    for ((i=0; i<=duration; i++)); do
        local filled=$((i * width / duration))
        local empty=$((width - filled))
        
        printf "\r${YELLOW}$message${NC} ["
        printf "%${filled}s" | tr ' ' '▓'
        printf "%${empty}s" | tr ' ' '░'
        printf "] %d%%" $((i * 100 / duration))
        
        sleep 0.05
    done
    
    echo -e " ${GREEN}✓${NC}"
}

# Enhanced confirmation with better UX
confirm() {
    local message="$1"
    local default="${2:-n}"
    local help_text="${3:-}"
    
    while true; do
        if [[ "$default" == "y" ]]; then
            local prompt="[Y/n]"
        else
            local prompt="[y/N]"
        fi
        
        echo -e "\n${YELLOW}$message${NC}"
        if [[ -n "$help_text" ]]; then
            echo -e "${CYAN}$help_text${NC}"
        fi
        echo -n -e "${WHITE}Choice $prompt: ${NC}"
        
        read -r response
        
        if [[ -z "$response" ]]; then
            response="$default"
        fi
        
        case "${response,,}" in
            y|yes|j|ja) return 0 ;;
            n|no|nein) return 1 ;;
            h|help|?)
                if [[ -n "$help_text" ]]; then
                    echo -e "\n${CYAN}Help: $help_text${NC}"
                else
                    echo -e "\n${CYAN}Enter 'y' for yes or 'n' for no${NC}"
                fi
                ;;
            *) echo -e "${RED}Invalid input. Please enter 'y' or 'n' (or 'h' for help)${NC}" ;;
        esac
    done
}

# Menu selection function
select_menu() {
    local title="$1"
    shift
    local options=("$@")
    local choice
    
    while true; do
        echo -e "\n${CYAN}${BOLD}$title${NC}"
        echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        for i in "${!options[@]}"; do
            echo -e "${WHITE}$((i+1)).${NC} ${options[i]}"
        done
        echo -e "${WHITE}0.${NC} Back/Cancel"
        
        echo -n -e "\n${YELLOW}Select option [0-${#options[@]}]: ${NC}"
        read -r choice
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 0 ]] && [[ "$choice" -le "${#options[@]}" ]]; then
            return "$choice"
        else
            echo -e "${RED}Invalid selection. Please enter a number between 0 and ${#options[@]}.${NC}"
            sleep 1
        fi
    done
}

# System detection with better error handling
detect_system() {
    print_step "Detecting system configuration..."
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        IS_ROOT=true
        print_warning "Running as root - some operations will be adjusted"
    fi
    
    # Detect distribution
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        DISTRO="$ID"
    elif command -v lsb_release >/dev/null 2>&1; then
        DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    else
        print_error "Cannot detect Linux distribution"
        exit 1
    fi
    
    # Set package manager
    case "$DISTRO" in
        ubuntu|debian|linuxmint)
            PACKAGE_MANAGER="apt"
            ;;
        centos|rhel|fedora|rocky|alma)
            PACKAGE_MANAGER="dnf"
            if ! command -v dnf >/dev/null 2>&1 && command -v yum >/dev/null 2>&1; then
                PACKAGE_MANAGER="yum"
            fi
            ;;
        arch|manjaro|endeavouros)
            PACKAGE_MANAGER="pacman"
            ;;
        opensuse*|sles)
            PACKAGE_MANAGER="zypper"
            ;;
        *)
            print_warning "Unsupported distribution: $DISTRO. Attempting to use apt..."
            PACKAGE_MANAGER="apt"
            ;;
    esac
    
    # Verify package manager exists
    if ! command -v "$PACKAGE_MANAGER" >/dev/null 2>&1; then
        print_error "Package manager '$PACKAGE_MANAGER' not found"
        exit 1
    fi
    
    print_success "Detected: $PRETTY_NAME with $PACKAGE_MANAGER"
}

# Check prerequisites
check_prerequisites() {
    print_step "Checking system prerequisites..."
    
    local missing_deps=()
    
    # Check essential commands
    for cmd in curl git; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    # Install missing dependencies
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_warning "Missing dependencies: ${missing_deps[*]}"
        install_basic_deps "${missing_deps[@]}"
    fi
    
    # Check sudo access (if not root)
    if [[ "$IS_ROOT" != true ]] && ! sudo -n true 2>/dev/null; then
        print_warning "Sudo access required. You may be prompted for your password."
        if ! sudo -v; then
            print_error "Cannot obtain sudo privileges"
            exit 1
        fi
    fi
    
    # Check internet connectivity
    print_info "Testing internet connectivity..."
    if ! ping -c 1 -W 5 8.8.8.8 >/dev/null 2>&1 && ! ping -c 1 -W 5 1.1.1.1 >/dev/null 2>&1; then
        print_error "No internet connection detected"
        exit 1
    fi
    
    print_success "All prerequisites satisfied"
}

# Install basic dependencies
install_basic_deps() {
    local deps=("$@")
    print_step "Installing basic dependencies: ${deps[*]}"
    
    case "$PACKAGE_MANAGER" in
        apt)
            sudo apt update -qq
            sudo apt install -y "${deps[@]}"
            ;;
        dnf|yum)
            sudo "$PACKAGE_MANAGER" install -y "${deps[@]}"
            ;;
        pacman)
            sudo pacman -Sy --noconfirm "${deps[@]}"
            ;;
        zypper)
            sudo zypper install -y "${deps[@]}"
            ;;
    esac
}

# =============================================================================
# Repository Management
# =============================================================================

# Clone or update repository
setup_repository() {
    print_header "Repository Setup"
    
    if [[ -d "$INSTALL_DIR" ]]; then
        print_info "Repository directory exists: $INSTALL_DIR"
        
        if confirm "Update existing repository?" "y" "This will pull the latest changes from GitHub"; then
            cd "$INSTALL_DIR"
            print_step "Updating repository..."
            git fetch origin
            git reset --hard origin/main
            print_success "Repository updated"
        fi
    else
        print_step "Cloning repository to $INSTALL_DIR..."
        git clone "$REPO_URL" "$INSTALL_DIR"
        cd "$INSTALL_DIR"
        print_success "Repository cloned successfully"
    fi
    
    # Make sure we're in the right directory
    if [[ ! -f "$INSTALL_DIR/setup.sh" ]]; then
        print_error "Setup script not found in repository"
        exit 1
    fi
}

# =============================================================================
# System Configuration
# =============================================================================

# Improved timezone configuration
configure_timezone() {
    print_section "Timezone Configuration"
    
    # Show current timezone
    local current_tz
    if command -v timedatectl >/dev/null 2>&1; then
        current_tz=$(timedatectl show --property=Timezone --value)
    else
        current_tz=$(cat /etc/timezone 2>/dev/null || echo "Unknown")
    fi
    
    print_info "Current timezone: $current_tz"
    
    if ! confirm "Change timezone?" "n" "Configure system timezone for accurate time display"; then
        return 0
    fi
    
    # Method 1: Use timedatectl (systemd systems)
    if command -v timedatectl >/dev/null 2>&1; then
        echo -e "\n${CYAN}Common timezones:${NC}"
        echo "1. Europe/Berlin"
        echo "2. Europe/London" 
        echo "3. America/New_York"
        echo "4. America/Los_Angeles"
        echo "5. Asia/Tokyo"
        echo "6. Asia/Shanghai"
        echo "7. Australia/Sydney"
        echo "8. Custom timezone"
        
        echo -n -e "\n${YELLOW}Select timezone [1-8]: ${NC}"
        read -r tz_choice
        
        local timezone=""
        case "$tz_choice" in
            1) timezone="Europe/Berlin" ;;
            2) timezone="Europe/London" ;;
            3) timezone="America/New_York" ;;
            4) timezone="America/Los_Angeles" ;;
            5) timezone="Asia/Tokyo" ;;
            6) timezone="Asia/Shanghai" ;;
            7) timezone="Australia/Sydney" ;;
            8) 
                echo -n -e "${YELLOW}Enter timezone (e.g., Europe/Paris): ${NC}"
                read -r timezone
                ;;
            *) 
                print_warning "Invalid selection, keeping current timezone"
                return 0
                ;;
        esac
        
        if [[ -n "$timezone" ]]; then
            if sudo timedatectl set-timezone "$timezone" 2>/dev/null; then
                print_success "Timezone set to $timezone"
            else
                print_error "Failed to set timezone to $timezone"
            fi
        fi
    else
        # Method 2: Manual configuration for older systems
        echo -n -e "${YELLOW}Enter timezone (e.g., Europe/Berlin): ${NC}"
        read -r timezone
        
        if [[ -f "/usr/share/zoneinfo/$timezone" ]]; then
            sudo ln -sf "/usr/share/zoneinfo/$timezone" /etc/localtime
            echo "$timezone" | sudo tee /etc/timezone >/dev/null
            print_success "Timezone set to $timezone"
        else
            print_error "Invalid timezone: $timezone"
        fi
    fi
}

# Improved locale configuration
configure_locales() {
    print_section "Locale Configuration"
    
    # Show current locale
    local current_locale=$(locale | grep LANG= | cut -d= -f2 | tr -d '"')
    print_info "Current locale: ${current_locale:-Not set}"
    
    if ! confirm "Configure locales?" "n" "Set system language and regional settings"; then
        return 0
    fi
    
    case "$PACKAGE_MANAGER" in
        apt)
            # For Debian/Ubuntu systems
            echo -e "\n${CYAN}Common locales:${NC}"
            echo "1. en_US.UTF-8 (English US)"
            echo "2. en_GB.UTF-8 (English UK)"
            echo "3. de_DE.UTF-8 (German)"
            echo "4. fr_FR.UTF-8 (French)"
            echo "5. es_ES.UTF-8 (Spanish)"
            echo "6. Custom locale"
            
            echo -n -e "\n${YELLOW}Select locale [1-6]: ${NC}"
            read -r locale_choice
            
            local locale=""
            case "$locale_choice" in
                1) locale="en_US.UTF-8" ;;
                2) locale="en_GB.UTF-8" ;;
                3) locale="de_DE.UTF-8" ;;
                4) locale="fr_FR.UTF-8" ;;
                5) locale="es_ES.UTF-8" ;;
                6) 
                    echo -n -e "${YELLOW}Enter locale (e.g., it_IT.UTF-8): ${NC}"
                    read -r locale
                    ;;
                *) 
                    print_warning "Invalid selection, keeping current locale"
                    return 0
                    ;;
            esac
            
            if [[ -n "$locale" ]]; then
                # Generate locale
                if sudo locale-gen "$locale" 2>/dev/null; then
                    # Set as system default
                    echo "LANG=$locale" | sudo tee /etc/default/locale >/dev/null
                    export LANG="$locale"
                    print_success "Locale set to $locale"
                    print_info "Please log out and back in for full locale changes"
                else
                    print_error "Failed to generate locale: $locale"
                fi
            fi
            ;;
        *)
            print_info "Locale configuration varies by distribution"
            print_info "Please configure manually using your distribution's tools"
            ;;
    esac
}

# =============================================================================
# User Management
# =============================================================================

# Enhanced user creation
create_user_interactive() {
    print_header "User Management"
    
    if ! confirm "Create a new user account?" "n" "Add a new system user with sudo privileges"; then
        return 0
    fi
    
    local username=""
    local password=""
    local confirm_password=""
    
    # Username input with validation
    while true; do
        echo -n -e "${YELLOW}Enter username: ${NC}"
        read -r username
        
        if [[ -z "$username" ]]; then
            print_error "Username cannot be empty"
            continue
        fi
        
        if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*$ ]] || [[ ${#username} -gt 32 ]]; then
            print_error "Invalid username. Use only lowercase letters, numbers, underscore, and dash (max 32 chars)"
            continue
        fi
        
        if id "$username" &>/dev/null; then
            print_warning "User '$username' already exists"
            if confirm "Configure existing user '$username'?" "y"; then
                configure_existing_user "$username"
                return 0
            else
                continue
            fi
        fi
        
        break
    done
    
    # Password input with confirmation
    while true; do
        echo -n -e "${YELLOW}Enter password for '$username': ${NC}"
        read -s password
        echo
        
        if [[ ${#password} -lt 8 ]]; then
            print_error "Password must be at least 8 characters long"
            continue
        fi
        
        echo -n -e "${YELLOW}Confirm password: ${NC}"
        read -s confirm_password
        echo
        
        if [[ "$password" == "$confirm_password" ]]; then
            break
        else
            print_error "Passwords do not match"
        fi
    done
    
    # Create user
    print_step "Creating user '$username'..."
    
    case "$PACKAGE_MANAGER" in
        apt)
            sudo adduser --disabled-password --gecos "" "$username" --quiet
            ;;
        dnf|yum|pacman|zypper)
            sudo useradd -m -s /bin/bash "$username"
            ;;
    esac
    
    # Set password
    echo "$username:$password" | sudo chpasswd
    
    # Configure user
    configure_user_privileges "$username"
    setup_user_environment "$username"
    
    INSTALL_USER="$username"
    print_success "User '$username' created and configured successfully"
}

# Configure user privileges
configure_user_privileges() {
    local username="$1"
    
    print_step "Configuring privileges for '$username'..."
    
    # Add to sudo group
    case "$PACKAGE_MANAGER" in
        apt)
            sudo usermod -aG sudo "$username"
            ;;
        dnf|yum|pacman|zypper)
            sudo usermod -aG wheel "$username"
            ;;
    esac
    
    print_success "Added '$username' to sudo group"
    
    # Optional passwordless sudo
    if confirm "Enable passwordless sudo for '$username'?" "n" "WARNING: This reduces security but improves convenience"; then
        setup_passwordless_sudo "$username"
    fi
    
    # Add to docker group (will be created later if needed)
    print_info "User will be added to docker group when Docker is installed"
}

# Setup passwordless sudo
setup_passwordless_sudo() {
    local username="$1"
    local sudoers_file="/etc/sudoers.d/90-${username}-nopasswd"
    
    print_step "Setting up passwordless sudo for '$username'..."
    
    # Create sudoers file
    echo "$username ALL=(ALL) NOPASSWD:ALL" | sudo tee "$sudoers_file" >/dev/null
    sudo chmod 440 "$sudoers_file"
    
    # Validate
    if sudo visudo -c -f "$sudoers_file" >/dev/null 2>&1; then
        print_success "Passwordless sudo configured"
        print_warning "Security Note: User '$username' can now run sudo without password"
    else
        print_error "Invalid sudoers configuration, removing file"
        sudo rm -f "$sudoers_file"
        return 1
    fi
}

# Enhanced user environment setup
setup_user_environment() {
    local username="$1"
    local user_home="/home/$username"
    
    print_step "Setting up environment for '$username'..."
    
    # Create directory structure
    sudo -u "$username" mkdir -p "$user_home"/{.ssh,.config,.local/bin,projects,scripts}
    
    # Setup shell configuration
    if [[ ! -f "$user_home/.bashrc" ]]; then
        sudo -u "$username" cp /etc/skel/.bashrc "$user_home/.bashrc" 2>/dev/null || \
        sudo -u "$username" touch "$user_home/.bashrc"
    fi
    
    # Add enhanced configuration
    sudo -u "$username" tee -a "$user_home/.bashrc" >/dev/null <<'BASHRC_EOF'

# ============================================================================= 
# Enhanced configuration by sakis-tech setup script
# =============================================================================

# Environment variables
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"
export EDITOR="nano"
export BROWSER="firefox"

# Enhanced prompt
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi

# Useful aliases
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# System aliases
alias update='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias search='apt search'
alias h='history'
alias c='clear'
alias reload='source ~/.bashrc'

# Docker aliases (available after Docker installation)
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dc='docker-compose'
alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'
alias dclogs='docker-compose logs -f'
alias dexec='docker exec -it'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gb='git branch'
alias gco='git checkout'
alias glog='git log --oneline --graph --decorate'

# Network and system info
alias myip='curl -s https://httpbin.org/ip | jq -r .origin'
alias ports='netstat -tulan'
alias processes='ps aux | grep -v grep | grep'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Functions
mkcd() { mkdir -p "$1" && cd "$1"; }
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Welcome message
echo -e "\033[1;32m🚀 Welcome to your enhanced development environment!\033[0m"
echo -e "\033[0;36mTip: Type 'alias' to see all available shortcuts\033[0m"

BASHRC_EOF
    
    # Set proper permissions
    sudo chown -R "$username:$username" "$user_home"
    sudo chmod 700 "$user_home/.ssh" 2>/dev/null || true
    
    print_success "Environment configured for '$username'"
}

# Configure existing user
configure_existing_user() {
    local username="$1"
    print_step "Configuring existing user '$username'..."
    
    configure_user_privileges "$username"
    setup_user_environment "$username"
    
    INSTALL_USER="$username"
    print_success "User '$username' configuration completed"
}

# =============================================================================
# Component Installation
# =============================================================================

# Main component selection menu
select_components() {
    print_header "Component Selection"
    
    local components=(
        "Base System Packages (git, nodejs, npm, jq, etc.) - RECOMMENDED"
        "Docker & Docker Compose - Container platform"
        "Claude Code CLI - AI development assistant"
        "Development Tools (vim, htop, tree, etc.)"
        "System Configuration (timezone, locales)"
        "AI Tools (claude-flow, Claude-Autopilot)"
    )
    
    SELECTED_COMPONENTS=()
    
    print_info "Select components to install (multiple selections possible):"
    
    for i in "${!components[@]}"; do
        if confirm "Install: ${components[i]}" "y"; then
            SELECTED_COMPONENTS+=("$i")
        fi
    done
    
    if [[ ${#SELECTED_COMPONENTS[@]} -eq 0 ]]; then
        print_warning "No components selected"
        return 1
    fi
    
    print_info "Selected components: ${#SELECTED_COMPONENTS[@]}"
    return 0
}

# Install base packages
install_base_packages() {
    print_section "Installing Base System Packages"
    
    local packages_apt=(
        "curl" "wget" "git" "unzip" "zip" "jq" "tree" "htop" "nano" "vim"
        "nodejs" "npm" "python3" "python3-pip" "build-essential"
        "software-properties-common" "apt-transport-https" "ca-certificates"
        "gnupg" "lsb-release" "net-tools" "openssh-client"
    )
    
    local packages_dnf=(
        "curl" "wget" "git" "unzip" "zip" "jq" "tree" "htop" "nano" "vim"
        "nodejs" "npm" "python3" "python3-pip" "gcc" "gcc-c++" "make"
        "openssh-clients" "net-tools"
    )
    
    local packages_pacman=(
        "curl" "wget" "git" "unzip" "zip" "jq" "tree" "htop" "nano" "vim"
        "nodejs" "npm" "python" "python-pip" "base-devel"
        "openssh" "net-tools"
    )
    
    case "$PACKAGE_MANAGER" in
        apt)
            print_step "Updating package lists..."
            sudo apt update -y
            show_progress 10 "Updating repositories"
            
            print_step "Upgrading existing packages..."
            sudo apt upgrade -y
            show_progress 20 "Upgrading system"
            
            print_step "Installing base packages..."
            sudo apt install -y "${packages_apt[@]}"
            show_progress 15 "Installing packages"
            
            print_step "Cleaning up..."
            sudo apt autoremove -y
            sudo apt autoclean
            show_progress 5 "Cleaning up"
            ;;
        dnf|yum)
            print_step "Installing base packages..."
            sudo "$PACKAGE_MANAGER" update -y
            sudo "$PACKAGE_MANAGER" install -y "${packages_dnf[@]}"
            show_progress 20 "Installing packages"
            ;;
        pacman)
            print_step "Installing base packages..."
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm "${packages_pacman[@]}"
            show_progress 20 "Installing packages"
            ;;
    esac
    
    print_success "Base packages installed successfully"
}

# Install Docker with enhanced configuration
install_docker() {
    print_section "Installing Docker"
    
    if command -v docker >/dev/null 2>&1; then
        print_info "Docker is already installed"
        local docker_version=$(docker --version | cut -d' ' -f3 | sed 's/,//')
        print_info "Current version: $docker_version"
        
        if ! confirm "Reinstall Docker?" "n"; then
            return 0
        fi
    fi
    
    case "$PACKAGE_MANAGER" in
        apt)
            # Remove old versions
            print_step "Removing old Docker versions..."
            sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
            
            # Add Docker's official GPG key and repository
            print_step "Adding Docker repository..."
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL "https://download.docker.com/linux/$DISTRO/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            sudo chmod a+r /etc/apt/keyrings/docker.gpg
            
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DISTRO $(lsb_release -cs) stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
            
            # Install Docker Engine
            print_step "Installing Docker Engine..."
            sudo apt update
            sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        dnf|yum)
            print_step "Installing Docker..."
            sudo "$PACKAGE_MANAGER" remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine 2>/dev/null || true
            sudo "$PACKAGE_MANAGER" install -y yum-utils
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            sudo "$PACKAGE_MANAGER" install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        pacman)
            print_step "Installing Docker..."
            sudo pacman -S --noconfirm docker docker-compose
            ;;
    esac
    
    show_progress 25 "Installing Docker"
    
    # Start and enable Docker service
    print_step "Configuring Docker service..."
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Add users to docker group
    if [[ "$IS_ROOT" != true ]]; then
        sudo usermod -aG docker "$CURRENT_USER"
        print_success "Added '$CURRENT_USER' to docker group"
    fi
    
    if [[ -n "$INSTALL_USER" && "$INSTALL_USER" != "$CURRENT_USER" ]]; then
        sudo usermod -aG docker "$INSTALL_USER"
        print_success "Added '$INSTALL_USER' to docker group"
    fi
    
    # Install Docker Compose standalone (fallback)
    install_docker_compose_standalone
    
    print_success "Docker installation completed"
    print_warning "Please log out and back in for docker group membership to take effect"
}

# Install standalone Docker Compose
install_docker_compose_standalone() {
    print_step "Installing Docker Compose standalone..."
    
    local compose_version
    compose_version=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name 2>/dev/null)
    
    if [[ -n "$compose_version" && "$compose_version" != "null" ]]; then
        local arch
        arch=$(uname -m)
        [[ "$arch" == "x86_64" ]] && arch="x86_64"
        [[ "$arch" == "aarch64" ]] && arch="aarch64"
        
        sudo curl -L "https://github.com/docker/compose/releases/download/${compose_version}/docker-compose-$(uname -s)-${arch}" \
            -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        
        # Create compatibility wrapper
        sudo tee /usr/local/bin/docker-compose-v1 >/dev/null <<'COMPOSE_WRAPPER'
#!/bin/bash
# Docker Compose compatibility wrapper
if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
else
    echo "Error: Neither docker compose plugin nor standalone docker-compose found!"
    exit 1
fi
COMPOSE_WRAPPER
        sudo chmod +x /usr/local/bin/docker-compose-v1
        
        print_success "Docker Compose installed: $compose_version"
    else
        print_warning "Could not determine latest Docker Compose version"
    fi
}

# Install Claude Code CLI
install_claude_code() {
    print_section "Installing Claude Code CLI"
    
    if command -v claude-code >/dev/null 2>&1; then
        print_info "Claude Code is already installed"
        if ! confirm "Reinstall Claude Code?" "n"; then
            return 0
        fi
    fi
    
    print_step "Installing Claude Code CLI..."
    
    # Check if install script is available
    if curl -fsSL https://claude.ai/cli/install.sh | bash; then
        show_progress 15 "Installing Claude Code"
        
        # Add to PATH for all users
        if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
            echo 'export PATH="/usr/local/bin:$PATH"' | sudo tee -a /etc/environment >/dev/null
        fi
        
        print_success "Claude Code CLI installed successfully"
        print_info "Run 'claude-code auth' to authenticate with your Claude account"
    else
        print_error "Failed to install Claude Code CLI"
        print_info "You can try installing manually from: https://claude.ai/cli"
    fi
}

# Install development tools
install_dev_tools() {
    print_section "Installing Development Tools"
    
    local tools_apt=("neofetch" "tmux" "screen" "rsync" "bat" "fd-find" "ripgrep")
    local tools_dnf=("neofetch" "tmux" "screen" "rsync" "bat" "fd-find" "ripgrep")
    local tools_pacman=("neofetch" "tmux" "screen" "rsync" "bat" "fd" "ripgrep")
    
    case "$PACKAGE_MANAGER" in
        apt)
            sudo apt install -y "${tools_apt[@]}" 2>/dev/null || print_warning "Some development tools may not be available"
            ;;
        dnf|yum)
            sudo "$PACKAGE_MANAGER" install -y "${tools_dnf[@]}" 2>/dev/null || print_warning "Some development tools may not be available"
            ;;
        pacman)
            sudo pacman -S --noconfirm "${tools_pacman[@]}" 2>/dev/null || print_warning "Some development tools may not be available"
            ;;
    esac
    
    show_progress 10 "Installing development tools"
    print_success "Development tools installed"
}

# Install AI tools from GitHub
install_ai_tools() {
    print_section "Installing AI Tools"
    
    local install_dir="$USER_HOME/ai-tools"
    mkdir -p "$install_dir"
    
    # Install claude-flow
    if confirm "Install claude-flow (AI workflow automation)?" "y"; then
        print_step "Installing claude-flow..."
        cd "$install_dir"
        
        if [[ -d "claude-flow" ]]; then
            cd claude-flow
            git pull
        else
            git clone https://github.com/ruvnet/claude-flow.git
            cd claude-flow
        fi
        
        # Install dependencies if available
        if [[ -f "package.json" ]] && command -v npm >/dev/null 2>&1; then
            npm install --silent
        fi
        
        if [[ -f "requirements.txt" ]] && command -v pip3 >/dev/null 2>&1; then
            pip3 install -r requirements.txt --quiet
        fi
        
        show_progress 10 "Installing claude-flow"
        print_success "claude-flow installed in $install_dir/claude-flow"
    fi
    
    # Install Claude-Autopilot
    if confirm "Install Claude-Autopilot (automated Claude interactions)?" "y"; then
        print_step "Installing Claude-Autopilot..."
        cd "$install_dir"
        
        if [[ -d "Claude-Autopilot" ]]; then
            cd Claude-Autopilot
            git pull
        else
            git clone https://github.com/benbasha/Claude-Autopilot.git
            cd Claude-Autopilot
        fi
        
        # Install dependencies if available
        if [[ -f "requirements.txt" ]] && command -v pip3 >/dev/null 2>&1; then
            pip3 install -r requirements.txt --quiet
        fi
        
        if [[ -f "package.json" ]] && command -v npm >/dev/null 2>&1; then
            npm install --silent
        fi
        
        show_progress 10 "Installing Claude-Autopilot"
        print_success "Claude-Autopilot installed in $install_dir/Claude-Autopilot"
    fi
    
    # Create convenient aliases
    if [[ -n "$INSTALL_USER" ]]; then
        local user_home="/home/$INSTALL_USER"
        echo -e "\n# AI Tools aliases" | sudo -u "$INSTALL_USER" tee -a "$user_home/.bashrc" >/dev/null
        echo "alias claude-flow='cd $install_dir/claude-flow && ./claude-flow.sh'" | sudo -u "$INSTALL_USER" tee -a "$user_home/.bashrc" >/dev/null
        echo "alias claude-autopilot='cd $install_dir/Claude-Autopilot && python3 main.py'" | sudo -u "$INSTALL_USER" tee -a "$user_home/.bashrc" >/dev/null
    fi
}

# =============================================================================
# Installation Orchestration
# =============================================================================

# Execute selected installations
execute_installations() {
    print_header "Installing Selected Components"
    
    local total_components=${#SELECTED_COMPONENTS[@]}
    local current=0
    
    for component_id in "${SELECTED_COMPONENTS[@]}"; do
        ((current++))
        print_info "Progress: $current/$total_components"
        
        case "$component_id" in
            0) install_base_packages ;;
            1) install_docker ;;
            2) install_claude_code ;;
            3) install_dev_tools ;;
            4) 
                configure_timezone
                configure_locales
                ;;
            5) install_ai_tools ;;
        esac
        
        echo ""  # Add spacing between components
    done
}

# =============================================================================
# System Information and Verification
# =============================================================================

# Show installation summary
show_installation_summary() {
    print_header "Installation Summary"
    
    # System information
    print_section "System Information"
    echo "OS: $(lsb_release -d 2>/dev/null | cut -f2 || echo "$(uname -s) $(uname -r)")"
    echo "Architecture: $(uname -m)"
    echo "Package Manager: $PACKAGE_MANAGER"
    echo "Current User: $CURRENT_USER"
    echo "Install Directory: $INSTALL_DIR"
    
    if [[ -n "$INSTALL_USER" ]]; then
        echo -e "\n${PURPLE}New User Created:${NC}"
        echo "Username: $INSTALL_USER"
        echo "Home: /home/$INSTALL_USER"
        echo "Groups: $(groups "$INSTALL_USER" 2>/dev/null | cut -d: -f2 | xargs)"
    fi
    
    # Installed software
    print_section "Installed Software"
    
    command -v git >/dev/null 2>&1 && echo "✓ Git: $(git --version | cut -d' ' -f3)"
    command -v node >/dev/null 2>&1 && echo "✓ Node.js: $(node --version)"
    command -v npm >/dev/null 2>&1 && echo "✓ NPM: $(npm --version)"
    command -v docker >/dev/null 2>&1 && echo "✓ Docker: $(docker --version | cut -d' ' -f3 | sed 's/,//')"
    command -v docker-compose >/dev/null 2>&1 && echo "✓ Docker Compose: $(docker-compose --version | cut -d' ' -f3 | sed 's/,//')"
    command -v claude-code >/dev/null 2>&1 && echo "✓ Claude Code: $(claude-code --version 2>/dev/null || echo "installed")"
    command -v jq >/dev/null 2>&1 && echo "✓ jq: $(jq --version)"
    command -v python3 >/dev/null 2>&1 && echo "✓ Python: $(python3 --version | cut -d' ' -f2)"
    
    # AI Tools
    [[ -d "$USER_HOME/ai-tools/claude-flow" ]] && echo "✓ claude-flow: $USER_HOME/ai-tools/claude-flow"
    [[ -d "$USER_HOME/ai-tools/Claude-Autopilot" ]] && echo "✓ Claude-Autopilot: $USER_HOME/ai-tools/Claude-Autopilot"
    
    echo -e "\n${GREEN}✓ Installation completed successfully!${NC}"
    echo -e "${YELLOW}Log file: $LOGFILE${NC}"
}

# Post-installation instructions
show_post_install_notes() {
    print_header "Post-Installation Notes"
    
    echo -e "${YELLOW}${BOLD}Important Next Steps:${NC}"
    echo ""
    echo "1. ${WHITE}Restart Session:${NC} Log out and back in to apply group changes"
    echo "2. ${WHITE}Reload Shell:${NC} Run 'source ~/.bashrc' or open a new terminal"
    echo "3. ${WHITE}Docker Test:${NC} Run 'docker run hello-world' to test Docker"
    
    if command -v claude-code >/dev/null 2>&1; then
        echo "4. ${WHITE}Claude Code:${NC} Run 'claude-code auth' to authenticate"
    fi
    
    if [[ -n "$INSTALL_USER" ]]; then
        echo ""
        echo -e "${CYAN}${BOLD}New User '$INSTALL_USER':${NC}"
        echo "• Switch: su - $INSTALL_USER"
        echo "• SSH: ssh $INSTALL_USER@$(hostname)"
        echo "• Enhanced shell with custom aliases and functions"
        
        if sudo test -f "/etc/sudoers.d/90-${INSTALL_USER}-nopasswd"; then
            echo -e "• ${RED}Security Note: Passwordless sudo enabled${NC}"
        fi
    fi
    
    echo ""
    echo -e "${CYAN}${BOLD}Useful Commands:${NC}"
    echo "• docker --version        # Check Docker"
    echo "• docker-compose --version # Check Docker Compose"
    echo "• claude-code --help      # Claude Code help"
    echo "• git --version           # Check Git"
    echo "• htop                    # System monitor"
    echo "• neofetch                # System info"
    
    echo ""
    echo -e "${CYAN}${BOLD}Repository Management:${NC}"
    echo "• Update: cd $INSTALL_DIR && git pull"
    echo "• Re-run: cd $INSTALL_DIR && ./setup.sh"
    
    echo ""
    echo -e "${GREEN}${BOLD}🎉 Setup Complete! Happy Coding! 🚀${NC}"
}

# =============================================================================
# Main Application Flow
# =============================================================================

# Main banner
show_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                      ║"
    echo "║    🚀 SAKIS-TECH COMPREHENSIVE SYSTEM SETUP v$SCRIPT_VERSION 🚀         ║"
    echo "║                                                                      ║"
    echo "║    Automated Development Environment Setup                           ║"
    echo "║    Enhanced • Stable • User-Friendly                                ║"
    echo "║                                                                      ║"
    echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Main function
main() {
    # Initialize
    setup_logging
    show_banner
    
    # System checks
    detect_system
    check_prerequisites
    
    # Repository setup
    setup_repository
    
    # User management
    create_user_interactive
    
    # Component selection
    if ! select_components; then
        print_error "No components selected. Exiting."
        exit 1
    fi
    
    # Confirmation
    print_header "Ready to Install"
    print_info "Selected ${#SELECTED_COMPONENTS[@]} components for installation"
    
    if ! confirm "Proceed with installation?" "y" "This will install the selected components on your system"; then
        print_info "Installation cancelled by user"
        exit 0
    fi
    
    # Execute installations
    execute_installations
    
    # Show results
    show_installation_summary
    show_post_install_notes
    
    print_info "Installation completed successfully!"
}

# =============================================================================
# Script Entry Point
# =============================================================================

# Trap for cleanup
trap 'echo -e "\n${RED}Installation interrupted by user${NC}"; exit 1' INT TERM

# Help function
show_help() {
    echo "Sakis-Tech System Setup Script v$SCRIPT_VERSION"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --version  Show version information"
    echo ""
    echo "This script provides an interactive menu to install:"
    echo "• Base system packages (git, nodejs, npm, etc.)"
    echo "• Docker and Docker Compose"
    echo "• Claude Code CLI"
    echo "• Development tools"
    echo "• System configuration (timezone, locales)"
    echo "• AI tools (claude-flow, Claude-Autopilot)"
    echo ""
    echo "Repository: $REPO_URL"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    -v|--version)
        echo "Sakis-Tech System Setup Script v$SCRIPT_VERSION"
        exit 0
        ;;
    "")
        # No arguments, run main
        main "$@"
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
