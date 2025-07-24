#!/bin/bash

# =============================================================================
# Comprehensive System Setup Script
# Author: sakis-tech
# Description: Automated setup script for development environment
# Usage: curl -fsSL https://raw.githubusercontent.com/sakis-tech/setup-scripts/main/setup.sh | bash
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging setup
LOGFILE="/tmp/setup-script-$(date +%Y%m%d-%H%M%S).log"
exec 1> >(tee -a "$LOGFILE")
exec 2> >(tee -a "$LOGFILE" >&2)

# Global variables
SCRIPT_VERSION="1.0.0"
USER_HOME="${HOME:-/home/$(logname 2>/dev/null || echo $USER)}"
DISTRO=""
PACKAGE_MANAGER=""

# =============================================================================
# Utility Functions
# =============================================================================

print_banner() {
    echo -e "${CYAN}"
    echo "=================================================================="
    echo "          🚀 SYSTEM SETUP SCRIPT v${SCRIPT_VERSION} 🚀"
    echo "=================================================================="
    echo -e "${NC}"
    echo -e "${YELLOW}This script will set up your development environment${NC}"
    echo -e "${YELLOW}Log file: ${LOGFILE}${NC}"
    echo ""
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

# Progress bar function
show_progress() {
    local duration=$1
    local message=$2
    echo -n -e "${YELLOW}${message}${NC} "
    for ((i=0; i<=duration; i++)); do
        echo -n "▓"
        sleep 0.1
    done
    echo -e " ${GREEN}✓${NC}"
}

# Confirm function
confirm() {
    local message="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        local prompt="[Y/n]"
    else
        local prompt="[y/N]"
    fi
    
    echo -n -e "${YELLOW}$message $prompt: ${NC}"
    read -r response
    
    if [[ -z "$response" ]]; then
        response="$default"
    fi
    
    case "$response" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

# Detect distribution
detect_distro() {
    print_step "Detecting Linux distribution..."
    
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO=$ID
    elif type lsb_release >/dev/null 2>&1; then
        DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    else
        DISTRO=$(uname -s | tr '[:upper:]' '[:lower:]')
    fi
    
    case "$DISTRO" in
        ubuntu|debian)
            PACKAGE_MANAGER="apt"
            ;;
        centos|rhel|fedora)
            PACKAGE_MANAGER="yum"
            if command -v dnf >/dev/null 2>&1; then
                PACKAGE_MANAGER="dnf"
            fi
            ;;
        arch|manjaro)
            PACKAGE_MANAGER="pacman"
            ;;
        *)
            print_warning "Unknown distribution: $DISTRO. Assuming apt..."
            PACKAGE_MANAGER="apt"
            ;;
    esac
    
    print_success "Detected: $DISTRO with $PACKAGE_MANAGER"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_warning "Running as root. Some operations will be adjusted accordingly."
        return 0
    else
        return 1
    fi
}

# Check prerequisites
check_prerequisites() {
    print_step "Checking prerequisites..."
    
    # Check if we have sudo access or are root
    if ! check_root && ! sudo -n true 2>/dev/null; then
        print_error "This script requires sudo privileges. Please run with sudo or as root."
        exit 1
    fi
    
    # Check internet connectivity
    if ! ping -c 1 google.com >/dev/null 2>&1; then
        print_error "No internet connection detected. Please check your network."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# =============================================================================
# User Management Functions
# =============================================================================

# Create new user with sudo and docker privileges
create_new_user() {
    print_step "User Management Setup"
    
    if ! confirm "Do you want to create a new user?" "n"; then
        return 0
    fi
    
    echo -e "\n${CYAN}=== USER CREATION ===${NC}"
    
    # Get username
    while true; do
        echo -n -e "${YELLOW}Enter username for new user: ${NC}"
        read -r new_username
        
        if [[ -z "$new_username" ]]; then
            print_error "Username cannot be empty"
            continue
        fi
        
        if [[ "$new_username" =~ ^[a-z_][a-z0-9_-]*$ ]] && [[ ${#new_username} -le 32 ]]; then
            break
        else
            print_error "Invalid username. Use only lowercase letters, numbers, underscore, and dash (max 32 chars)"
        fi
    done
    
    # Check if user already exists
    if id "$new_username" &>/dev/null; then
        print_info "User '$new_username' already exists"
        
        if confirm "Do you want to configure this existing user?" "y"; then
            configure_existing_user "$new_username"
        fi
        return 0
    fi
    
    # Get password
    while true; do
        echo -n -e "${YELLOW}Enter password for user '$new_username': ${NC}"
        read -s new_password
        echo
        
        if [[ ${#new_password} -lt 6 ]]; then
            print_error "Password must be at least 6 characters long"
            continue
        fi
        
        echo -n -e "${YELLOW}Confirm password: ${NC}"
        read -s confirm_password
        echo
        
        if [[ "$new_password" == "$confirm_password" ]]; then
            break
        else
            print_error "Passwords do not match"
        fi
    done
    
    # Create user
    print_step "Creating user '$new_username'..."
    
    case "$PACKAGE_MANAGER" in
        apt)
            sudo adduser --disabled-password --gecos "" "$new_username"
            ;;
        yum|dnf)
            sudo useradd -m -s /bin/bash "$new_username"
            ;;
        pacman)
            sudo useradd -m -s /bin/bash "$new_username"
            ;;
    esac
    
    # Set password
    echo "$new_username:$new_password" | sudo chpasswd
    
    if [[ $? -eq 0 ]]; then
        print_success "User '$new_username' created successfully"
    else
        print_error "Failed to create user '$new_username'"
        return 1
    fi
    
    # Configure user privileges
    configure_user_privileges "$new_username"
    
    # Setup user environment
    setup_user_environment "$new_username"
    
    print_success "User '$new_username' setup completed"
    
    # Ask if user wants to switch to new user
    if confirm "Do you want to switch to the new user '$new_username' for the rest of the installation?" "n"; then
        print_info "Switching to user '$new_username'..."
        export INSTALL_USER="$new_username"
        USER_HOME="/home/$new_username"
        print_warning "Note: You may need to re-authenticate for sudo operations"
    fi
}

# Configure existing user
configure_existing_user() {
    local username="$1"
    print_step "Configuring existing user '$username'..."
    
    configure_user_privileges "$username"
    setup_user_environment "$username"
    
    print_success "User '$username' configuration completed"
}

# Configure user privileges (sudo and docker)
configure_user_privileges() {
    local username="$1"
    
    print_step "Configuring privileges for user '$username'..."
    
    # Add to sudo group
    case "$PACKAGE_MANAGER" in
        apt)
            sudo usermod -aG sudo "$username"
            ;;
        yum|dnf|pacman)
            sudo usermod -aG wheel "$username"
            ;;
    esac
    
    print_success "Added '$username' to sudo group"
    
    # Ask about passwordless sudo
    if confirm "Do you want to enable passwordless sudo for user '$username'?" "n"; then
        setup_passwordless_sudo "$username"
    fi
    
    # Add to docker group (if docker will be or is installed)
    if command -v docker >/dev/null 2>&1 || confirm "Add user '$username' to docker group? (recommended if installing Docker)" "y"; then
        # Create docker group if it doesn't exist
        if ! getent group docker >/dev/null; then
            sudo groupadd docker
        fi
        
        sudo usermod -aG docker "$username"
        print_success "Added '$username' to docker group"
    fi
}

# Setup passwordless sudo
setup_passwordless_sudo() {
    local username="$1"
    local sudoers_file="/etc/sudoers.d/90-${username}-nopasswd"
    
    print_step "Setting up passwordless sudo for '$username'..."
    
    # Create sudoers file with proper permissions
    echo "$username ALL=(ALL) NOPASSWD:ALL" | sudo tee "$sudoers_file" > /dev/null
    sudo chmod 440 "$sudoers_file"
    
    # Validate sudoers file
    if sudo visudo -c -f "$sudoers_file" >/dev/null 2>&1; then
        print_success "Passwordless sudo configured for '$username'"
        print_warning "Security Note: User '$username' can now run sudo without password"
    else
        print_error "Error in sudoers configuration. Removing file..."
        sudo rm -f "$sudoers_file"
        return 1
    fi
}

# Setup user environment
setup_user_environment() {
    local username="$1"
    local user_home="/home/$username"
    
    print_step "Setting up environment for user '$username'..."
    
    # Create common directories
    sudo -u "$username" mkdir -p "$user_home"/{.ssh,.config,bin,projects}
    
    # Setup shell configuration
    if [[ ! -f "$user_home/.bashrc" ]]; then
        sudo -u "$username" cp /etc/skel/.bashrc "$user_home/.bashrc" 2>/dev/null || true
    fi
    
    # Add useful aliases and environment variables
    sudo -u "$username" tee -a "$user_home/.bashrc" > /dev/null <<'EOF'

# Added by setup script
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Useful aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Docker aliases
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dc='docker-compose'
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
alias dcl='docker-compose logs -f'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gb='git branch'
alias gco='git checkout'

# System aliases
alias update='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias search='apt search'
alias ll='ls -la'
alias h='history'
alias c='clear'

# Claude Code alias (if installed)
if command -v claude-code >/dev/null 2>&1; then
    alias cc='claude-code'
    alias claude='claude-code'
fi

echo "🚀 Development environment ready! Type 'claude-code --help' to get started with AI assistance."
EOF
    
    # Set proper ownership
    sudo chown -R "$username:$username" "$user_home"
    
    # Setup SSH directory with proper permissions
    sudo chmod 700 "$user_home/.ssh" 2>/dev/null || true
    
    print_success "Environment setup completed for '$username'"
}

# Display user information
show_user_info() {
    local username="$1"
    
    echo -e "\n${PURPLE}User Information:${NC}"
    echo "Username: $username"
    echo "Home Directory: /home/$username"
    echo "Shell: $(getent passwd "$username" | cut -d: -f7)"
    
    echo -e "\n${PURPLE}Group Memberships:${NC}"
    groups "$username" | sed 's/.*: //' | tr ' ' '\n' | sort | sed 's/^/  ✓ /'
    
    echo -e "\n${PURPLE}Sudo Configuration:${NC}"
    if sudo -l -U "$username" 2>/dev/null | grep -q "NOPASSWD"; then
        echo "  ✓ Passwordless sudo enabled"
    else
        echo "  ✓ Standard sudo access (password required)"
    fi
}

# =============================================================================
# Installation Functions
# =============================================================================

# Update system and install base packages
install_base_packages() {
    print_step "Updating system and installing base packages..."
    
    case "$PACKAGE_MANAGER" in
        apt)
            sudo apt update -y
            show_progress 10 "Updating package lists"
            
            sudo apt upgrade -y
            show_progress 20 "Upgrading packages"
            
            sudo apt install -y sudo curl git unzip nodejs npm jq wget gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release
            show_progress 15 "Installing base packages"
            
            sudo apt autoremove -y
            show_progress 5 "Cleaning up"
            ;;
        yum|dnf)
            sudo $PACKAGE_MANAGER update -y
            sudo $PACKAGE_MANAGER install -y sudo curl git unzip nodejs npm jq wget gnupg2
            ;;
        pacman)
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm sudo curl git unzip nodejs npm jq wget gnupg
            ;;
    esac
    
    print_success "Base packages installed successfully"
}

# Configure timezone and locales
configure_system() {
    print_step "Configuring system settings..."
    
    if confirm "Do you want to configure timezone?" "y"; then
        if command -v timedatectl >/dev/null 2>&1; then
            echo -e "${CYAN}Available timezones (showing common ones):${NC}"
            timedatectl list-timezones | grep -E "(Europe|America|Asia)/(Berlin|London|New_York|Los_Angeles|Tokyo)" | head -10
            echo -n -e "${YELLOW}Enter timezone (e.g., Europe/Berlin) or press Enter for current: ${NC}"
            read -r timezone
            if [[ -n "$timezone" ]]; then
                sudo timedatectl set-timezone "$timezone"
                print_success "Timezone set to $timezone"
            fi
        else
            sudo dpkg-reconfigure tzdata
        fi
    fi
    
    if confirm "Do you want to configure locales?" "y"; then
        if [[ "$PACKAGE_MANAGER" == "apt" ]]; then
            sudo dpkg-reconfigure locales
        else
            print_info "Locale configuration varies by distribution. Please configure manually if needed."
        fi
    fi
}

# Install Docker
install_docker() {
    print_step "Installing Docker..."
    
    if command -v docker >/dev/null 2>&1; then
        print_info "Docker is already installed"
    else
        case "$PACKAGE_MANAGER" in
            apt)
                # Remove old versions
                sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
                
                # Add Docker's official GPG key
                sudo mkdir -p /etc/apt/keyrings
                curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                
                # Add repository
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DISTRO $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                
                # Install Docker Engine
                sudo apt update
                sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                ;;
            yum|dnf)
                sudo $PACKAGE_MANAGER install -y yum-utils
                sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
                sudo $PACKAGE_MANAGER install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                ;;
            pacman)
                sudo pacman -S --noconfirm docker docker-compose
                ;;
        esac
        
        show_progress 20 "Installing Docker"
    fi
    
    # Start and enable Docker
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Add current user to docker group
    if ! check_root; then
        sudo usermod -aG docker $USER
        print_success "Added $USER to docker group"
    fi
    
    # Add new user to docker group if one was created
    if [[ -n "$INSTALL_USER" && "$INSTALL_USER" != "$USER" ]]; then
        sudo usermod -aG docker "$INSTALL_USER"
        print_success "Added $INSTALL_USER to docker group"
    fi
    
    if ! check_root; then
        print_warning "Please log out and back in for docker group membership to take effect"
    fi
    
    print_success "Docker installation completed"
}

# Install Docker Compose standalone and wrapper
install_docker_compose() {
    print_step "Installing Docker Compose..."
    
    # Install Docker Compose standalone
    local compose_version=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)
    
    if [[ -n "$compose_version" && "$compose_version" != "null" ]]; then
        sudo curl -L "https://github.com/docker/compose/releases/download/${compose_version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        
        # Create docker-compose wrapper for newer docker compose plugin
        sudo tee /usr/local/bin/docker-compose-wrapper > /dev/null <<'EOF'
#!/bin/bash
# Docker Compose wrapper - works with both standalone and plugin versions
if command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
elif docker compose version >/dev/null 2>&1; then
    docker compose "$@"
else
    echo "Neither docker-compose nor docker compose plugin found!"
    exit 1
fi
EOF
        sudo chmod +x /usr/local/bin/docker-compose-wrapper
        
        show_progress 10 "Installing Docker Compose"
        print_success "Docker Compose installed: $compose_version"
    else
        print_error "Failed to get Docker Compose version"
    fi
}

# Install Claude Code
install_claude_code() {
    print_step "Installing Claude Code..."
    
    if command -v claude-code >/dev/null 2>&1; then
        print_info "Claude Code is already installed"
    else
        # Download and install Claude Code
        curl -fsSL https://claude.ai/cli/install.sh | bash
        
        # Add to PATH if not already there
        if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
            echo 'export PATH="/usr/local/bin:$PATH"' >> "$USER_HOME/.bashrc"
            echo 'export PATH="/usr/local/bin:$PATH"' >> "$USER_HOME/.zshrc" 2>/dev/null || true
        fi
        
        show_progress 15 "Installing Claude Code"
        print_success "Claude Code installed successfully"
        print_info "Run 'claude-code --help' to get started"
    fi
}

# Install optional GitHub projects
install_optional_projects() {
    print_step "Optional GitHub Projects Installation"
    
    # Claude Flow
    if confirm "Do you want to install claude-flow (AI workflow automation)?" "n"; then
        print_step "Installing claude-flow..."
        cd "$USER_HOME"
        
        if [[ -d "claude-flow" ]]; then
            print_info "claude-flow directory exists, updating..."
            cd claude-flow
            git pull
        else
            git clone https://github.com/ruvnet/claude-flow.git
            cd claude-flow
        fi
        
        # Install dependencies if package.json exists
        if [[ -f "package.json" ]]; then
            npm install
        fi
        
        # Make executable if there's a main script
        if [[ -f "claude-flow.sh" ]]; then
            chmod +x claude-flow.sh
        fi
        
        show_progress 10 "Installing claude-flow"
        print_success "claude-flow installed in $USER_HOME/claude-flow"
        cd "$USER_HOME"
    fi
    
    # Claude Autopilot
    if confirm "Do you want to install Claude-Autopilot (automated Claude interactions)?" "n"; then
        print_step "Installing Claude-Autopilot..."
        cd "$USER_HOME"
        
        if [[ -d "Claude-Autopilot" ]]; then
            print_info "Claude-Autopilot directory exists, updating..."
            cd Claude-Autopilot
            git pull
        else
            git clone https://github.com/benbasha/Claude-Autopilot.git
            cd Claude-Autopilot
        fi
        
        # Install dependencies if requirements.txt exists
        if [[ -f "requirements.txt" ]]; then
            if command -v pip3 >/dev/null 2>&1; then
                pip3 install -r requirements.txt
            elif command -v pip >/dev/null 2>&1; then
                pip install -r requirements.txt
            else
                print_warning "pip not found. Please install Python dependencies manually."
            fi
        fi
        
        # Install Node.js dependencies if package.json exists
        if [[ -f "package.json" ]]; then
            npm install
        fi
        
        show_progress 10 "Installing Claude-Autopilot"
        print_success "Claude-Autopilot installed in $USER_HOME/Claude-Autopilot"
        cd "$USER_HOME"
    fi
}

# System information and verification
verify_installation() {
    print_step "Verifying installations..."
    
    echo -e "\n${CYAN}=== INSTALLATION SUMMARY ===${NC}"
    
    # System info
    echo -e "\n${PURPLE}System Information:${NC}"
    echo "OS: $(lsb_release -d 2>/dev/null | cut -f2 || echo "$(uname -s) $(uname -r)")"
    echo "Architecture: $(uname -m)"
    echo "Current User: $(whoami)"
    echo "Home Directory: $USER_HOME"
    
    # Show new user info if created
    if [[ -n "$INSTALL_USER" && "$INSTALL_USER" != "$(whoami)" ]]; then
        echo -e "\n${PURPLE}New User Created:${NC}"
        show_user_info "$INSTALL_USER"
    fi
    
    # Installed software versions
    echo -e "\n${PURPLE}Installed Software:${NC}"
    
    if command -v git >/dev/null 2>&1; then
        echo "✓ Git: $(git --version | cut -d' ' -f3)"
    fi
    
    if command -v node >/dev/null 2>&1; then
        echo "✓ Node.js: $(node --version)"
    fi
    
    if command -v npm >/dev/null 2>&1; then
        echo "✓ NPM: $(npm --version)"
    fi
    
    if command -v docker >/dev/null 2>&1; then
        echo "✓ Docker: $(docker --version | cut -d' ' -f3 | sed 's/,//')"
    fi
    
    if command -v docker-compose >/dev/null 2>&1; then
        echo "✓ Docker Compose: $(docker-compose --version | cut -d' ' -f3 | sed 's/,//')"
    fi
    
    if command -v claude-code >/dev/null 2>&1; then
        echo "✓ Claude Code: $(claude-code --version 2>/dev/null || echo "installed")"
    fi
    
    if command -v jq >/dev/null 2>&1; then
        echo "✓ jq: $(jq --version)"
    fi
    
    # Optional projects
    echo -e "\n${PURPLE}Optional Projects:${NC}"
    [[ -d "$USER_HOME/claude-flow" ]] && echo "✓ claude-flow: $USER_HOME/claude-flow"
    [[ -d "$USER_HOME/Claude-Autopilot" ]] && echo "✓ Claude-Autopilot: $USER_HOME/Claude-Autopilot"
    
    echo -e "\n${GREEN}Installation completed successfully!${NC}"
    echo -e "${YELLOW}Log file saved to: ${LOGFILE}${NC}"
}

# Cleanup function
cleanup() {
    print_step "Performing cleanup..."
    
    case "$PACKAGE_MANAGER" in
        apt)
            sudo apt autoremove -y
            sudo apt autoclean
            ;;
        yum|dnf)
            sudo $PACKAGE_MANAGER autoremove -y
            sudo $PACKAGE_MANAGER clean all
            ;;
        pacman)
            sudo pacman -Sc --noconfirm
            ;;
    esac
    
    print_success "Cleanup completed"
}

# Post-installation notes
show_post_install_notes() {
    echo -e "\n${CYAN}=== POST-INSTALLATION NOTES ===${NC}"
    echo -e "${YELLOW}Important:${NC}"
    echo "1. If Docker was installed, please log out and back in for group membership to take effect"
    echo "2. Restart your terminal or run 'source ~/.bashrc' to reload PATH"
    echo "3. For Claude Code, you may need to authenticate: run 'claude-code auth'"
    
    # Additional notes for new user
    if [[ -n "$INSTALL_USER" && "$INSTALL_USER" != "$(whoami)" ]]; then
        echo -e "\n${YELLOW}New User '$INSTALL_USER':${NC}"
        echo "• Switch to new user: su - $INSTALL_USER"
        echo "• User has been added to sudo and docker groups"
        echo "• Custom aliases and environment variables are configured"
        if sudo test -f "/etc/sudoers.d/90-${INSTALL_USER}-nopasswd"; then
            echo "• ⚠️  Passwordless sudo is enabled (security consideration)"
        fi
    fi
    
    echo ""
    echo -e "${YELLOW}Useful commands:${NC}"
    echo "• docker --version"
    echo "• docker-compose --version"
    echo "• claude-code --help"
    echo "• git --version"
    
    # Show custom aliases if new user was created
    if [[ -n "$INSTALL_USER" ]]; then
        echo -e "\n${YELLOW}Custom aliases (for new user):${NC}"
        echo "• ll, la - enhanced ls commands"
        echo "• dps, dpa, di - docker shortcuts"
        echo "• dc, dcu, dcd - docker-compose shortcuts"
        echo "• gs, ga, gc, gp - git shortcuts"
        echo "• cc, claude - claude-code shortcuts"
    fi
    
    echo ""
    echo -e "${YELLOW}Optional project locations:${NC}"
    [[ -d "$USER_HOME/claude-flow" ]] && echo "• claude-flow: $USER_HOME/claude-flow"
    [[ -d "$USER_HOME/Claude-Autopilot" ]] && echo "• Claude-Autopilot: $USER_HOME/Claude-Autopilot"
    echo ""
    echo -e "${GREEN}Setup completed! Happy coding! 🚀${NC}"
}

# =============================================================================
# Main Function
# =============================================================================

main() {
    # Trap to handle script interruption
    trap 'echo -e "\n${RED}Script interrupted by user${NC}"; exit 1' INT TERM
    
    print_banner
    
    # Main installation flow
    check_prerequisites
    detect_distro
    
    # User management (early in the process)
    create_new_user
    
    echo -e "\n${CYAN}=== INSTALLATION MENU ===${NC}"
    echo "This script will install the following components:"
    echo "• System updates and base packages (git, nodejs, npm, jq, etc.)"
    echo "• Docker and Docker Compose"
    echo "• Claude Code CLI"
    echo "• Optional: claude-flow and Claude-Autopilot"
    echo ""
    
    if ! confirm "Do you want to proceed with the installation?" "y"; then
        echo -e "${YELLOW}Installation cancelled by user${NC}"
        exit 0
    fi
    
    # Core installations
    install_base_packages
    configure_system
    install_docker
    install_docker_compose
    install_claude_code
    
    # Optional installations
    install_optional_projects
    
    # Final steps
    cleanup
    verify_installation
    show_post_install_notes
    
    echo -e "\n${GREEN}🎉 All done! Script completed successfully! 🎉${NC}"
}

# =============================================================================
# Script Entry Point
# =============================================================================

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
