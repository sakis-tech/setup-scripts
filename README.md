# 🚀 Comprehensive System Setup Script

Ein umfassendes und benutzerfreundliches Setup-Script für die schnelle Einrichtung einer Entwicklungsumgebung auf Linux-Systemen.

## ✨ Features

### 🔧 Basis-Installation
- **System Updates**: Automatische Updates des Systems
- **Basis-Pakete**: `sudo`, `curl`, `git`, `unzip`, `nodejs`, `npm`, `jq`
- **System-Konfiguration**: Timezone und Locales
- **Benutzerverwaltung**: Neuen Benutzer erstellen mit sudo und Docker-Rechten
- **Cleanup**: Automatische Bereinigung nach Installation

### 👤 Benutzerverwaltung
- **Neuer Benutzer**: Interaktive Erstellung mit sicherem Passwort
- **Sudo-Rechte**: Automatisch zur sudo/wheel-Gruppe hinzugefügt
- **Passwordless Sudo**: Optional aktivierbar
- **Docker-Integration**: Automatisch zur Docker-Gruppe hinzugefügt
- **Shell-Konfiguration**: Vorkonfigurierte Aliases und Umgebungsvariablen
- **Docker Engine**: Neueste stabile Version
- **Docker Compose**: Standalone Version + Plugin
- **docker-compose Wrapper**: Kompatibilität mit beiden Versionen
- **Benutzer-Konfiguration**: Automatisches Hinzufügen zur Docker-Gruppe

### 🤖 AI-Tools
- **Claude Code**: Offizielle Claude CLI
- **Optional**: claude-flow (AI Workflow Automation)
- **Optional**: Claude-Autopilot (Automatisierte Claude-Interaktionen)

### 🛡️ Sicherheit & Stabilität
- **Error Handling**: Robuste Fehlerbehandlung
- **Logging**: Detaillierte Logs für Debugging
- **Interaktive Bestätigungen**: Benutzergesteuerte Installation
- **Distribution Detection**: Unterstützung für Ubuntu, Debian, CentOS, Fedora, Arch

## 🚀 Installation

### Direkte Online-Ausführung (Empfohlen)

```bash
curl -fsSL https://raw.githubusercontent.com/sakis-tech/setup-scripts/main/setup.sh | bash
```

### Alternative: SSH-Ausführung

```bash
# Für Remote-Server
ssh user@server "curl -fsSL https://raw.githubusercontent.com/sakis-tech/setup-scripts/main/setup.sh | bash"
```

### Mit wget (falls curl nicht verfügbar)

```bash
wget -qO- https://raw.githubusercontent.com/sakis-tech/setup-scripts/main/setup.sh | bash
```

### Lokale Ausführung

```bash
# Script herunterladen
curl -fsSL https://raw.githubusercontent.com/sakis-tech/setup-scripts/main/setup.sh -o setup.sh

# Ausführbar machen
chmod +x setup.sh

# Ausführen
./setup.sh
```

## 📋 Systemanforderungen

### Mindestanforderungen
- **Betriebssystem**: Linux (Ubuntu, Debian, CentOS, Fedora, Arch)
- **Berechtigung**: sudo-Zugriff oder root
- **Internet**: Aktive Internetverbindung
- **Speicher**: Mindestens 2GB freier Speicherplatz

### Getestete Distributionen
- ✅ Ubuntu 20.04, 22.04, 24.04
- ✅ Debian 11, 12
- ✅ CentOS 7, 8, 9
- ✅ Fedora 38, 39, 40
- ✅ Arch Linux (aktuell)

## 🎛️ Interaktive Features

Das Script bietet folgende interaktive Optionen:

1. **Benutzerverwaltung**: 
   - Neuen Benutzer erstellen
   - Benutzer zur sudo-Gruppe hinzufügen
   - Passwordless sudo konfigurieren (optional)
   - Automatisch zur Docker-Gruppe hinzufügen
2. **Timezone-Konfiguration**: Auswahl der gewünschten Zeitzone
3. **Locale-Einstellungen**: Konfiguration der Systemsprache
4. **Optionale Projekte**: 
   - claude-flow Installation (ja/nein)
   - Claude-Autopilot Installation (ja/nein)

### 👤 Benutzerverwaltung im Detail

Das Script bietet eine umfassende Benutzerverwaltung:

- **Sichere Benutzererstellung**: Validierung von Benutzername und Passwort
- **Berechtigungen**: Automatisches Hinzufügen zu sudo/wheel und docker Gruppen
- **Passwordless Sudo**: Optional aktivierbar für Entwicklungsumgebungen
- **Shell-Konfiguration**: 
  - Vorkonfigurierte `.bashrc` mit nützlichen Aliases
  - Docker, Git und System-Shortcuts
  - PATH-Konfiguration für lokale Binaries
  - Claude Code Integrationen

**Verfügbare Aliases für neue Benutzer:**
```bash
# System
ll, la, l          # Erweiterte ls-Kommandos
update, install    # APT-Shortcuts
c, h              # Clear, History

# Docker
dps, dpa, di      # docker ps, ps -a, images
dc, dcu, dcd      # docker-compose up/down
dcl               # docker-compose logs -f

# Git
gs, ga, gc        # git status, add, commit
gp, gl, gb        # git push, pull, branch
gco               # git checkout

# Claude Code
cc, claude        # claude-code shortcuts
```

## 📊 Installationsübersicht

Nach der Installation erhalten Sie eine detaillierte Übersicht:

```
=== INSTALLATION SUMMARY ===

System Information:
OS: Ubuntu 22.04.3 LTS
Architecture: x86_64
Current User: root
Home Directory: /root

New User Created:
Username: developer
Home Directory: /home/developer
Shell: /bin/bash

Group Memberships:
  ✓ developer
  ✓ docker
  ✓ sudo

Sudo Configuration:
  ✓ Passwordless sudo enabled

Installed Software:
✓ Git: 2.34.1
✓ Node.js: v18.17.0
✓ NPM: 9.6.7
✓ Docker: 24.0.6
✓ Docker Compose: 2.21.0
✓ Claude Code: installed
✓ jq: 1.6

Optional Projects:
✓ claude-flow: /home/developer/claude-flow
✓ Claude-Autopilot: /home/developer/Claude-Autopilot
```

## 🔧 Verwendung nach Installation

### Benutzerwechsel

Wenn ein neuer Benutzer erstellt wurde:

```bash
# Zu neuem Benutzer wechseln
su - developer

# Oder via SSH (falls Remote)
ssh developer@server

# Benutzer-Informationen anzeigen
id
groups
sudo -l  # Sudo-Berechtigungen prüfen
```

### Docker
```bash
# Docker-Version prüfen
docker --version

# Docker Compose testen
docker-compose --version
# oder
docker compose --version

# Erstes Container-Test
docker run hello-world
```

### Claude Code
```bash
# Authentifizierung (erforderlich beim ersten Mal)
claude-code auth

# Hilfe anzeigen
claude-code --help

# Beispiel-Nutzung
claude-code "Create a Python script for file organization"
```

### Optionale Projekte

#### claude-flow
```bash
cd ~/claude-flow
# Weitere Anweisungen in der Projekt-README
```

#### Claude-Autopilot
```bash
cd ~/Claude-Autopilot
# Konfiguration und Nutzung siehe Projekt-Dokumentation
```

## 📝 Logs und Debugging

Das Script erstellt automatisch detaillierte Logs:

```bash
# Log-Datei finden (wird am Ende der Installation angezeigt)
ls -la /tmp/setup-script-*.log

# Log-Inhalt anzeigen
tail -f /tmp/setup-script-YYYYMMDD-HHMMSS.log
```

## 🛠️ Erweiterte Optionen

### Umgebungsvariablen

Einige Aspekte können durch Umgebungsvariablen gesteuert werden:

```bash
# Automatische Bestätigung für alle Fragen
export AUTO_CONFIRM=yes

# Benutzerdefinierte Installation ohne optionale Projekte
export SKIP_OPTIONAL=yes

# Script ausführen
curl -fsSL https://raw.githubusercontent.com/sakis-tech/setup-scripts/main/setup.sh | bash
```

### Nur bestimmte Komponenten installieren

```bash
# Nur Docker installieren (kommende Version)
curl -fsSL https://raw.githubusercontent.com/sakis-tech/setup-scripts/main/setup.sh | bash -s -- --only-docker

# Nur Claude Code installieren (kommende Version)
curl -fsSL https://raw.githubusercontent.com/sakis-tech/setup-scripts/main/setup.sh | bash -s -- --only-claude
```

## ❗ Wichtige Hinweise

### Nach der Installation
1. **Neuanmeldung erforderlich**: Für Docker-Gruppenmitgliedschaft
2. **Terminal neustarten**: Für PATH-Updates
3. **Claude Code authentifizieren**: `claude-code auth`

### Berechtigungen
- Das Script benötigt sudo-Rechte für Systeminstallationen
- Benutzer wird automatisch zur Docker-Gruppe hinzugefügt
- Keine root-Ausführung erforderlich (aber möglich)

### Sicherheit
- Script ist idempotent (mehrfache Ausführung sicher)
- Überprüfung vorhandener Installationen
- Automatische Backup-Erstellung bei Konfigurationsänderungen
- **Passwordless sudo**: Optional und nur auf Wunsch aktiviert
- **Sichere Passwort-Eingabe**: Versteckte Eingabe mit Bestätigung
- **Benutzervalidierung**: Prüfung auf gültige Benutzernamen

## 🐛 Fehlerbehebung

### Häufige Probleme

#### Docker-Berechtigung
```bash
# Problem: "permission denied while trying to connect to Docker daemon"
# Lösung: Neuanmeldung oder temporäre Gruppenwechsel
newgrp docker
```

#### Claude Code Authentifizierung
```bash
# Problem: "Authentication required"
# Lösung: 
claude-code auth
# Folgen Sie den Anweisungen im Browser
```

#### Benutzer-Probleme
```bash
# Problem: "User not in sudoers file"
# Lösung: Benutzer zur sudo-Gruppe hinzufügen
sudo usermod -aG sudo username

# Problem: "Permission denied" bei Docker
# Lösung: Benutzer zur Docker-Gruppe hinzufügen
sudo usermod -aG docker username
newgrp docker  # Oder neu anmelden

# Problem: Passwordless sudo funktioniert nicht
# Lösung: Sudoers-Datei prüfen
sudo visudo -f /etc/sudoers.d/90-username-nopasswd
```

#### Netzwerk-Probleme
```bash
# Problem: Download-Fehler
# Lösung: DNS und Proxy prüfen
nslookup github.com
curl -I https://github.com
```

### Support

Bei Problemen:

1. **Log-Datei prüfen**: Detaillierte Fehlermeldungen in `/tmp/setup-script-*.log`
2. **Issue erstellen**: [GitHub Issues](https://github.com/sakis-tech/setup-scripts/issues)
3. **Pull Request**: Verbesserungen sind willkommen!

## 🤝 Mitwirken

Beiträge sind herzlich willkommen! Bitte:

1. Fork des Repositories
2. Feature-Branch erstellen (`git checkout -b feature/amazing-feature`)
3. Änderungen committen (`git commit -m 'Add amazing feature'`)
4. Branch pushen (`git push origin feature/amazing-feature`)
5. Pull Request erstellen

## 📄 Lizenz

Dieses Projekt steht unter der MIT-Lizenz - siehe [LICENSE.md](LICENSE.md) für Details.

## 🙏 Danksagungen

- [Docker](https://docker.com) für die Container-Technologie
- [Anthropic](https://anthropic.com) für Claude und Claude Code
- [ruvnet](https://github.com/ruvnet) für claude-flow
- [benbasha](https://github.com/benbasha) für Claude-Autopilot

## 📈 Statistiken

![Script Usage](https://img.shields.io/github/downloads/sakis-tech/setup-scripts/total)
![Latest Release](https://img.shields.io/github/v/release/sakis-tech/setup-scripts)
![Issues](https://img.shields.io/github/issues/sakis-tech/setup-scripts)
![License](https://img.shields.io/github/license/sakis-tech/setup-scripts)

---

**Made with ❤️ by [sakis-tech](https://github.com/sakis-tech)**

*Automatisiere deine Entwicklungsumgebung und spare wertvolle Zeit!*
