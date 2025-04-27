// Name: Dark Mode
// Description: Enable dark mode
// Author: Jatinderjit Singh
// Twitter: @jatinderjit

import "@johnlindquist/kit"

import { usePowerShell } from 'zx'

usePowerShell()

await $`New-ItemProperty -Path HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force`
await $`New-ItemProperty -Path HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force`
