# Windows-Forensics
Automated digital forensics tool - file carving, memory analysis, PCAP inspection &amp; string extraction using Bash
🔍 Windows Forensics Tool
Automated Digital Forensics & Memory Analysis Tool
Developed by: Noam Shafir

📌 Overview
A comprehensive Bash-based automation tool designed to streamline the key phases of a digital forensics investigation.
The script automates file carving, memory analysis, network traffic inspection, and string extraction — all in a single structured workflow, outputting a clean report and compressed ZIP archive.

🚀 Key Features

Root Verification — Ensures the script runs with the required privileges before execution
Tool Setup — Interactive installer for all required forensic tools (Foremost, Bulk Extractor, Binwalk, TShark, Strings)
File Carving — Extracts embedded files and artifacts using Foremost and Bulk Extractor
String Analysis — Extracts targeted strings from the file, filtering by keywords: password, user, exe, root, error, http, system
PCAP Detection — Automatically searches for extracted PCAP files and presents a structured TShark traffic summary
Memory Analysis — If the input is a memory dump, runs Volatility 3 to extract process list (pslist), process tree (pstree), and network connections (netstat) — auto-detects OS format (Windows / Linux / Mac)
Report & Archive — Generates a structured summary report and compresses all results into a ZIP file for easy delivery


🛠️ Tech Stack & Requirements
Language: Bash
Tools used (typically found on Kali Linux):
ToolPurposeForemostFile carvingBulk ExtractorArtifact extractionStringsKeyword-based string extractionTSharkPCAP traffic analysisVolatility 3Memory dump analysisBinwalkFirmware / binary analysis (optional)

⚙️ Installation & Usage
Clone the repository:
bashgit clone https://github.com/khunixx/Windows-Forensics
cd Windows-Forensics
Grant execution permissions:
bashchmod +x forensics.sh
Run with Root privileges:
bashsudo ./forensics.sh

🔄 Scan Workflow
Root Check → Tool Setup → File Input → Carving → PCAP Check → Memory Analysis → Report & ZIP

📂 Output Structure
output_folder/
├── bulk_data/        # Bulk Extractor artifacts
├── fore_data/        # Foremost carved files
├── strings_data/     # Keyword-filtered string results
│   ├── pass.txt
│   ├── exe.txt
│   ├── user.txt
│   ├── root.txt
│   ├── error.txt
│   ├── valid.txt
│   ├── system.txt
│   └── http.txt
├── VOL_data/         # Volatility memory analysis (if applicable)
│   ├── pslist.txt
│   ├── pstree.txt
│   └── netstat.txt
└── report.txt        # Summary report
output_folder.zip     # Compressed archive of all results

⚠️ Disclaimer
This tool is intended for educational and ethical forensics purposes only.
Usage of this tool on systems or files without proper authorization is illegal.
The developer assumes no liability for any misuse or damage caused by this program.
