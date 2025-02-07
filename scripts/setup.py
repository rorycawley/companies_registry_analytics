#!/usr/bin/env python3

"""
Project Setup Script
Creates and validates the project's environment configuration.
Supports Windows, macOS, and Linux platforms.
Requires config/.env.example file to be present.
"""

import sys
import shutil
import platform
import tempfile
from pathlib import Path
from typing import Optional, Tuple


def check_platform_compatibility() -> Tuple[bool, str]:
    """
    Verifies platform-specific requirements and permissions.
    Returns (success, error_message).
    """
    system = platform.system()
    if system not in {'Windows', 'Darwin', 'Linux'}:
        return False, f"Unsupported operating system: {system}"

    try:
        with tempfile.NamedTemporaryFile(mode='w+', encoding='utf-8') as tf:
            tf.write('test')
            tf.seek(0)
            tf.read()
        return True, ""
    except Exception as e:
        return False, f"File operation test failed: {str(e)}"


def normalize_line_endings(content: str) -> str:
    """
    Normalizes line endings based on the platform.
    Windows uses CRLF, Unix-based systems use LF.
    """
    content = content.replace('\r\n', '\n')
    if platform.system() == 'Windows':
        return content.replace('\n', '\r\n')
    return content


def validate_env_file(filepath: Path) -> bool:
    """
    Validates that environment file contains all required variables.
    Handles different line endings and file encodings.
    """
    required_vars = {
        'SUPERSET_SECRET_KEY',
        'SUPERSET_PORT',
        'SUPERSET_WORKERS',
        'SUPERSET_TIMEOUT',
        'DUCKDB_DATABASE'
    }

    try:
        content = filepath.read_text(encoding='utf-8')
        lines = content.replace('\r\n', '\n').split('\n')
        found_vars = {
            line.split('=')[0].strip()
            for line in lines
            if line.strip() and not line.startswith('#')
        }

        missing_vars = required_vars - found_vars
        if missing_vars:
            print(
                f"Missing required variables: {', '.join(sorted(missing_vars))}")
            return False
        return True
    except UnicodeDecodeError:
        print(f"Error: {filepath} must be saved with UTF-8 encoding")
        return False
    except Exception as e:
        print(f"Error validating {filepath}: {str(e)}")
        return False


def read_env_file(filepath: Path) -> Optional[str]:
    """
    Safely reads and returns environment file contents.
    Handles platform-specific line endings.
    """
    try:
        content = filepath.read_text(encoding='utf-8')
        return normalize_line_endings(content)
    except Exception as e:
        print(f"Error reading {filepath}: {str(e)}")
        return None


def verify_file_permissions(path: Path) -> bool:
    """
    Verifies read/write permissions for the given path.
    Handles platform-specific permission checking.
    """
    try:
        if not path.parent.exists():
            path.parent.mkdir(parents=True, exist_ok=True)

        test_file = path.parent / f'.test_{id(path)}'
        try:
            test_file.touch()
            test_file.unlink()
            return True
        except Exception:
            return False
    except Exception:
        return False


def setup() -> int:
    """
    Sets up project environment with enhanced cross-platform compatibility.
    Returns 0 for success, 1 for failure.
    """
    try:
        print("Starting project setup...")

        # Verify platform compatibility
        compatible, error = check_platform_compatibility()
        if not compatible:
            print(f"Platform compatibility check failed: {error}")
            return 1

        # Use absolute paths with new directory structure
        project_root = Path(__file__).parent.parent.absolute()
        env_file = project_root / '.env'
        env_example_file = project_root / 'config' / '.env.example'

        # Create required directories
        data_dir = project_root / 'data'
        data_dir.mkdir(exist_ok=True)

        # Verify permissions
        if not verify_file_permissions(env_file):
            print(f"Error: Insufficient permissions in {project_root}")
            return 1

        if env_file.exists():
            print(".env file already exists, skipping creation")
        else:
            if not env_example_file.exists():
                print(
                    f"Error: .env.example not found in {env_example_file.parent}")
                return 1

            if not env_example_file.is_file():
                print("Error: .env.example is not a regular file")
                return 1

            try:
                content = env_example_file.read_text(encoding='utf-8')
                env_file.write_text(
                    normalize_line_endings(content),
                    encoding='utf-8'
                )
                print(".env file created successfully")
            except Exception as e:
                print(f"Error creating .env file: {str(e)}")
                return 1

        if not validate_env_file(env_file):
            return 1

        if env_contents := read_env_file(env_file):
            print("\n--- .env file contents: ---")
            print(env_contents.rstrip())
            print("----------------------------")
        else:
            return 1

        print("\nNext steps:")
        print("1. Review and edit the .env file, particularly SUPERSET_SECRET_KEY")
        print("2. Run 'make env-check' to validate the environment")
        print("3. Run 'make start' to launch the services")

        return 0

    except Exception as e:
        print(f"Unexpected error during setup: {str(e)}")
        return 1


if __name__ == "__main__":
    sys.exit(setup())
