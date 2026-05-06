#!/bin/bash
# Build helper script for ConnectAgentApp on WSL

set -e

PROJECT_DIR="/home/danie/proyectos/connectCenter/Android/ConnectAgentApp"
GRADLE_BIN="/home/danie/.gradle/gradle-8.4/bin/gradle"

cd "$PROJECT_DIR"

echo "Building ConnectAgentApp..."
echo "Using Gradle: $GRADLE_BIN"
echo "Project: $PROJECT_DIR"
echo "---"

"$GRADLE_BIN" \
  -Dorg.gradle.java.home=/usr/lib/jvm/java-17-amazon-corretto \
  --project-dir="$PROJECT_DIR" \
  "$@"
