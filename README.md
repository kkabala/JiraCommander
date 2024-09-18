# JiraPower - PowerShell Scripts for Jira Automation

**JiraPower** is a collection of PowerShell Core scripts designed to streamline your day-to-day Jira tasks. Whether you're managing issues, logging time, or simply trying to stay on top of your workload, these scripts will help you automate repetitive tasks and improve your efficiency.

## Getting Started

### Prerequisites

Before running these scripts, you need to have **PowerShell Core** installed on your machine. You can download and install it from [PowerShell GitHub Releases](https://github.com/PowerShell/PowerShell/releases).

```bash
# Example for installing PowerShell Core on macOS using Homebrew
brew install --cask powershell

# Example for installing on Windows using the installer
# Download from: https://github.com/PowerShell/PowerShell/releases
```

### Installation

1. Clone or download this repository to your local machine.
2. Ensure that you have PowerShell Core installed (see Prerequisites).

### First-time Setup

When you run the **`Startup.ps1`** script for the first time, it will check if a `Config.psm1` file exists. If not, the script will prompt you to provide some necessary information:

1. **Jira URL**: The URL of your Jira instance (e.g., `https://jira.your-organisation-name.com`).
2. **Jira Username**: Your Jira username, typically in `Name.Surname` format.
3. **Project Prefixes to Ignore**: Any project prefixes you'd like to ignore while running scripts (optional, separated by commas).

After setting up, you can always modify the configuration by editing the `Config.psm1` file.

### Usage

1. Open a terminal and navigate to the directory where you cloned this repository.
2. Run the **`Startup.ps1`** script to begin:
   ```bash
   pwsh Startup.ps1
   ```
3. The script will display a menu with available commands.
4. Press the number corresponding to the script you want to execute, or press `q` to quit.

### Available Commands

The following commands are currently supported:

- **Find an issue**: Search for Jira issues based on a query.
- **Log Time**: Log work hours against a Jira issue.
- **Open an issue the browser**: Open a Jira issue in your default web browser.
- **Print my issues**: Display issues assigned to you.
- **Show Today's Timesheet**: Show the time you've logged today across multiple issues.
- **Tasks In Review**: List tasks currently in the "In Review" status.
---

## Contributing

Feel free to submit pull requests if you'd like to contribute new scripts or improve the existing ones.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
