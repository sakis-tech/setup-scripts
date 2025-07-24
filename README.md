# 🚀 Comprehensive System Setup Script v2.0

Ein **vollständig überarbeitetes**, benutzerfreundliches und stabiles Setup-Script für die schnelle Einrichtung einer professionellen Entwicklungsumgebung auf Linux-Systemen.

## ✨ Features

### 🎯 **Kernfunktionen**
- **📁 Git-basierter Workflow**: Clont sich selbst lokal, arbeitet vom Repository aus
- **🔧 Komponentenbasierte Installation**: Wähle nur was du brauchst
- **👤 Erweiterte Benutzerverwaltung**: Sichere Benutzer-Erstellung mit sudo/docker-Rechten
- **🛡️ Stabile System-Konfiguration**: Keine dpkg-reconfigure Probleme mehr
- **🎨 Intuitive Benutzerführung**: Farbige Menüs, Progress-Bars, klare Strukturen

### 🔧 **System-Unterstützung**
- **Distributionen**: Ubuntu, Debian, CentOS, Fedora, Arch Linux, OpenSUSE
- **Package Manager**: apt, dnf/yum, pacman, zypper
- **Architekturen**: x86_64, aarch64 (ARM64)

### 📦 **Installierbare Komponenten**

#### **1. Base System Packages**
```
git, nodejs, npm, python3, jq, tree, htop, vim, nano
build-essential, curl, wget, unzip, openssh-client
```

#### **2. Docker & Container Tools**
```
Docker Engine, Docker Compose Plugin
Docker Compose Standalone (Fallback)
Automatische Benutzer-Gruppenzugehörigkeit
Service-Konfiguration und Auto-Start
```

#### **3. Claude Code CLI**
```
Offizielle Claude AI CLI
PATH-Integration
Authentifizierungs-Unterstützung
```

#### **4. Development Tools**
```
neofetch, tmux, screen, rsync
bat, fd-find, ripgrep (falls verfügbar)
Enhanced shell configuration
```

#### **5. System Configuration**
```
Timezone: Interaktive Auswahl (timedatectl basiert)
Locales: Sichere locale-gen Konfiguration
Keine problematischen dpkg-reconfigure Aufrufe
```

#### **6. AI Tools (GitHub-basiert)**
```
claude-flow: AI Workflow Automation
Claude-Autopilot: Automatisierte Claude-Interaktionen
Automatische Dependency-Installation
```

## 🚀 Installation

### **Methode 1: Direkte Online-Ausführung (Empfohlen)**

```bash
# Vollständige Installation mit Repository-Clone
curl -fsSL https://raw.githubusercontent.com/sakis-tech/setup-scripts/main/setup.sh | bash
```

### **Methode 2: Git Clone (für Entwickler)**

```bash
# Repository clonen
git clone https://github.com/sakis-tech/setup-scripts.git
cd setup-scripts

# Script ausführen
./setup.sh
```

### **Methode 3: SSH/Remote-Installation**

```bash
# Für Remote-Server
ssh user@server "curl -fsSL https://raw.githubusercontent.com/sakis-tech/setup-scripts/main/setup.sh | bash"
```

## 🎛️ **Interaktive Bedienung**

### **Schritt 1: System-Erkennung**
```
🚀 SAKIS-TECH COMPREHENSIVE SYSTEM SETUP v2.0 🚀

[STEP] Detecting system configuration...
[SUCCESS] Detected: Ubuntu 22.04.3 LTS with apt
[STEP] Checking system prerequisites...
[SUCCESS] All prerequisites satisfied
```

### **Schritt 2: Repository Setup**
```
▓▓▓ Repository Setup ▓▓▓

[STEP] Cloning repository to /home/user/sakis-tech-setup...
[SUCCESS] Repository cloned successfully
```

### **Schritt 3: Benutzerverwaltung**
```
▓▓▓ User Management ▓▓▓

Create a new user account? [y/N]
This will add a new system user with sudo privileges
```

### **Schritt 4: Komponenten-Auswahl**
```
▓▓▓ Component Selection ▓▓▓

Select components to install (multiple selections possible):

Install: Base System Packages (git, nodejs, npm, jq, etc.) - RECOMMENDED [Y/n]: y
Install: Docker & Docker Compose - Container platform [Y/n]: y
Install: Claude Code CLI - AI development assistant [Y/n]: y
Install: Development Tools (vim, htop, tree, etc.) [Y/n]: n
Install: System Configuration (timezone, locales) [Y/n]: y
Install: AI Tools (claude-flow, Claude-Autopilot) [Y/n]: n
```

### **Schritt 5: Installation**
```
▓▓▓ Installing Selected Components ▓▓▓

Progress: 1/4
━━━ Installing Base System Packages ━━━
[STEP] Updating package lists...
Updating repositories [▓▓▓▓▓▓▓▓▓▓░░░░░░░] 67% ✓
```

## 📊 **Installation Summary**

Nach erfolgreicher Installation erhältst du eine detaillierte Übersicht:

```
▓▓▓ Installation Summary ▓▓▓

━━━ System Information ━━━
OS: Ubuntu 22.04.3 LTS
Architecture: x86_64
Package Manager: apt
Current User: sakis
Install Directory: /home/sakis/sakis-tech-setup

━━━ New User Created ━━━
Username: developer
Home: /home/developer
Groups: developer sudo docker

━━━ Installed Software ━━━
✓ Git: 2.34.1
✓ Node.js: v18.17.0
✓ NPM: 9.6.7
✓ Docker: 24.0.6
✓ Docker Compose: 2.21.0
✓ Claude Code: installed
✓ Python: 3.10.12

✓ Installation completed successfully!
Log file: /home/sakis/.local/share/sakis-tech-setup/logs/setup-20250724-195030.log
```

## 🔧 **Post-Installation**

### **Wichtige nächste Schritte:**
```
▓▓▓ Post-Installation Notes ▓▓▓

Important Next Steps:

1. Restart Session: Log out and back in to apply group changes
2. Reload Shell: Run 'source ~/.bashrc' or open a new terminal  
3. Docker Test: Run 'docker run hello-world' to test Docker
4. Claude Code: Run 'claude-code auth' to authenticate
```

### **Neue Benutzer-Features:**
```bash
# Enhanced shell mit custom aliases
ll, la          # Erweiterte ls-Kommandos
dps, dpsa, di   # Docker shortcuts  
gs, ga, gc, gp  # Git shortcuts
update, install # System shortcuts

# Nützliche Funktionen
mkcd dirname    # Verzeichnis erstellen und wechseln
extract file    # Automatisches Entpacken aller Archive-Typen
myip           # Externe IP-Adresse anzeigen
```

## 🛠️ **Erweiterte Verwendung**

### **Repository-Management**
```bash
# Ins Repository-Verzeichnis wechseln
cd ~/sakis-tech-setup

# Updates vom GitHub holen
git pull

# Script erneut ausführen
./setup.sh

# Komponenten nachinstallieren
./setup.sh  # Erkennt bereits installierte Komponenten
```

### **System-Konfiguration**

#### **Timezone-Konfiguration (verbessert)**
```bash
# Interaktive Auswahl statt dpkg-reconfigure
Available timezones:
1. Europe/Berlin
2. Europe/London
3. America/New_York
4. America/Los_Angeles
5. Asia/Tokyo
6. Asia/Shanghai
7. Australia/Sydney
8. Custom timezone

Select timezone [1-8]: 1
[SUCCESS] Timezone set to Europe/Berlin
```

#### **Locale-Konfiguration (stabil)**
```bash
# Sichere locale-gen statt dpkg-reconfigure
Common locales:
1. en_US.UTF-8 (English US)
2. en_GB.UTF-8 (English UK)  
3. de_DE.UTF-8 (German)
4. fr_FR.UTF-8 (French)
5. es_ES.UTF-8 (Spanish)
6. Custom locale

Select locale [1-6]: 3
[SUCCESS] Locale set to de_DE.UTF-8
```

## 📁 **Verzeichnisstruktur**

Nach der Installation:
```
~/sakis-tech-setup/          # Haupt-Repository
├── setup.sh                 # Haupt-Script
├── README.md                # Diese Dokumentation
└── .git/                    # Git-Repository

~/.local/share/sakis-tech-setup/logs/  # Log-Dateien
~/.config/sakis-tech-setup/           # Konfiguration

~/ai-tools/                   # AI Tools (optional)
├── claude-flow/             # claude-flow Repository
└── Claude-Autopilot/        # Claude-Autopilot Repository
```

## 🐛 **Fehlerbehebung**

### **Häufige Probleme**

#### **Repository-Clone Fehler**
```bash
# Manueller Clone falls automatisch fehlschlägt
git clone https://github.com/sakis-tech/setup-scripts.git ~/sakis-tech-setup
cd ~/sakis-tech-setup
./setup.sh
```

#### **Docker-Permissions**
```bash
# Nach Docker-Installation
sudo usermod -aG docker $USER
newgrp docker  # Oder neu anmelden
docker run hello-world  # Test
```

#### **Timezone/Locale Probleme**
```bash
# Manuelle Timezone-Konfiguration
sudo timedatectl set-timezone Europe/Berlin

# Manuelle Locale-Konfiguration  
sudo locale-gen de_DE.UTF-8
sudo update-locale LANG=de_DE.UTF-8
```

#### **Claude Code Authentifizierung**
```bash
# Nach Installation authentifizieren
claude-code auth
# Folge den Browser-Anweisungen
```

## 📋 **Systemanforderungen**

### **Mindestanforderungen**
- **OS**: Linux (Ubuntu 18.04+, Debian 10+, CentOS 7+, Fedora 30+, Arch Linux)
- **RAM**: 2GB (4GB empfohlen für Docker)
- **Disk**: 5GB freier Speicherplatz
- **Network**: Internetverbindung für Downloads
- **User**: sudo-Rechte oder root-Zugang

### **Getestete Systeme**
- ✅ Ubuntu 20.04, 22.04, 24.04
- ✅ Debian 11, 12
- ✅ CentOS 7, 8, 9 / Rocky Linux / AlmaLinux
- ✅ Fedora 38, 39, 40
- ✅ Arch Linux (aktuell)
- ✅ openSUSE Leap / Tumbleweed

## 🤝 **Mitwirken**

### **Entwicklung**
```bash
# Repository forken und clonen
git clone https://github.com/dein-username/setup-scripts.git
cd setup-scripts

# Branch für Feature erstellen
git checkout -b feature/amazing-feature

# Änderungen committen
git commit -m 'Add amazing feature'

# Push und Pull Request erstellen
git push origin feature/amazing-feature
```

### **Bug Reports**
- 🐛 [GitHub Issues](https://github.com/sakis-tech/setup-scripts/issues)
- 📧 **Log-Dateien** immer mit anhängen: `~/.local/share/sakis-tech-setup/logs/`

## 📄 **Changelog**

### **v2.0.0 - Major Overhaul**
- ✨ Git-basierter Workflow statt One-Liner
- 🔧 Stabile Timezone/Locale-Konfiguration
- 🎨 Komplett neue, intuitive Benutzeroberfläche
- 🛡️ Robuste Fehlerbehandlung und Validierung
- 📦 Komponentenbasierte Auswahl-System
- 👤 Erweiterte Benutzerverwaltung mit Enhanced Shell
- 🐳 Verbesserte Docker-Installation mit Fallbacks
- 📊 Detaillierte Progress-Anzeigen und Logging

### **v1.0.0 - Initial Release**
- 🚀 Basis-Funktionalität
- 🐳 Docker Installation
- 🤖 Claude Code Integration

## 📊 **Statistiken**

![GitHub Release](https://img.shields.io/github/v/release/sakis-tech/setup-scripts)
![GitHub Issues](https://img.shields.io/github/issues/sakis-tech/setup-scripts)
![GitHub Stars](https://img.shields.io/github/stars/sakis-tech/setup-scripts)
![GitHub Forks](https://img.shields.io/github/forks/sakis-tech/setup-scripts)

## 📄 **Lizenz**

Dieses Projekt steht unter der MIT-Lizenz - siehe [LICENSE](LICENSE) für Details.

## 🙏 **Danksagungen**

- [Docker](https://docker.com) für die Container-Technologie
- [Anthropic](https://anthropic.com) für Claude und Claude Code
- [ruvnet](https://github.com/ruvnet) für claude-flow
- [benbasha](https://github.com/benbasha) für Claude-Autopilot
- Die Open-Source Community für die großartigen Tools

---

**Made with ❤️ by [sakis-tech](https://github.com/sakis-tech)**

*Automatisiere deine Entwicklungsumgebung mit Stil und Stabilität! 🚀*

## 🎯 **Quick Start Guide**

```bash
# 1. Eine Zeile - alles installieren
curl -fsSL https://raw.githubusercontent.com/sakis-tech/setup-scripts/main/setup.sh | bash

# 2. Den Anweisungen folgen
# 3. Neu anmelden
# 4. Entwickeln! 🚀
```
