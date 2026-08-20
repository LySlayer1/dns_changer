# dns_changer

This script is a robust, interactive CLI network management utility for Windows that automates TCP/IP and DNS stack reconfigurations without requiring manual Control Panel navigation.

Core Architectural Features

Self-Elevating Execution: Uses netsession to check for administrative context and dynamically spawns a temporary VBScript (getadmin.vbs) to re-launch itself via UAC (runas) if privileges are missing.

Interface Operations: Leverages native netsh interface ip commands to toggle between static configurations and DHCP pools for both IPv4 address assignments and DNS resolvers.

Input Validation & Flow Control: Implemented error checks handle empty network adapter inputs and out-of-bound menu choices, looping back to input prompts rather than crashing the shell context.

Regional Resolver Mapping: Hardcodes verified primary/secondary DNS endpoints categorized by target geographical infrastructure (LY, RU, EU, US), while leaving room for manual user overrides.

Cache Hygiene: Automatically triggers ipconfig /flushdns upon completing configuration changes to clear stale resolver entries from the Windows DNS client cache.

Technical Observations & Optimizations

Variable Expansion: setlocal EnableDelayedExpansion is initialized at the start. While standard %VAR% syntax is currently used throughout the script (which works fine given the execution flow), using !VAR! inside nested IF blocks prevents edge-case variable evaluation issues in batch scripts.

DNS Table Wiping: When changing static DNS servers via netsh interface ip set dns ... static, Windows automatically replaces the primary entry. Using index=2 cleanly appends the secondary resolver without requiring a full adapter wipe first.

Silent Error Redirection: The >nul 2>&1 piping keeps the UI clean during state changes while the %errorlevel% check under :SETIP ensures invalid IP/Subnet inputs trigger a warning instead of failing silently.
