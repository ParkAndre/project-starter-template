#!/bin/bash
# Project Starter Template Installer
# Fetches project starter template from GitHub repository
# Usage: curl -fsSL <url-to-this-script> | bash

set -e

# GitHub repository configuration
GITHUB_USER="${TEMPLATE_GITHUB_USER:-adevtec}"
GITHUB_REPO="${TEMPLATE_GITHUB_REPO:-project-starter-template}"
GITHUB_BRANCH="${TEMPLATE_GITHUB_BRANCH:-main}"
BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📦 Project Starter Template Installer${NC}"
echo -e "${BLUE}======================================${NC}\n"

# Create .claude directory
echo -e "${YELLOW}Creating .claude directory...${NC}"
mkdir -p .claude

# Download files
echo -e "${YELLOW}Downloading template files...${NC}"

files=(
    "CLAUDE.md"
    ".gitignore"
    "GETTING_STARTED.md"
    ".claude/security.md"
    ".claude/testing.md"
    ".claude/api-design.md"
    ".claude/structure.md"
    ".claude/database.md"
    ".claude/standards.md"
)

for file in "${files[@]}"; do
    echo -e "  Downloading ${file}..."
    if command -v curl &> /dev/null; then
        curl -fsSL "${BASE_URL}/${file}" -o "${file}"
    elif command -v wget &> /dev/null; then
        wget -q "${BASE_URL}/${file}" -O "${file}"
    else
        echo -e "${YELLOW}⚠️  Neither curl nor wget found. Please install one.${NC}"
        exit 1
    fi
done

echo -e "\n${GREEN}✓ All files downloaded successfully!${NC}\n"

# Update .gitignore if it exists
if [ -f ".gitignore" ]; then
    if ! grep -q ".claude/settings.local.json" .gitignore; then
        echo -e "${YELLOW}Updating .gitignore...${NC}"
        echo "" >> .gitignore
        echo "# Claude Code local settings" >> .gitignore
        echo ".claude/settings.local.json" >> .gitignore
        echo -e "${GREEN}✓ Updated .gitignore${NC}"
    fi
fi

echo -e "\n${BLUE}======================================${NC}"
echo -e "${GREEN}✓ Installation complete!${NC}"
echo -e "${BLUE}======================================${NC}\n"

echo -e "${GREEN}📖 Quick Start:${NC}"
echo -e "  Read ${BLUE}GETTING_STARTED.md${NC} for step-by-step instructions\n"

echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. ${BLUE}CUSTOMIZE${NC} CLAUDE.md 'Common Commands' section with your project commands"
echo -e "  2. ${BLUE}REVIEW${NC} .gitignore and add project-specific ignores"
echo -e "  3. ${BLUE}COMMIT${NC} files to your repository"
echo -e "  4. ${BLUE}TEST${NC} it works - ask Claude: 'What are our commit message conventions?'"
echo -e "  5. ${BLUE}START${NC} coding - Claude now follows your guidelines automatically!\n"

echo -e "${BLUE}Verify it's working:${NC}"
echo -e "  Ask Claude: ${YELLOW}'What are our security rules?'${NC}"
echo -e "  If Claude answers correctly, you're all set! ✨\n"

echo -e "${BLUE}Tip:${NC} Press ${YELLOW}#${NC} in Claude Code to quickly edit CLAUDE.md during conversation\n"
